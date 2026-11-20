class Organization < ApplicationRecord
  has_and_belongs_to_many :landscapes
  has_and_belongs_to_many :users
  has_many :organization_join_requests, dependent: :destroy
  has_many :organizations_countries, dependent: :destroy, autosave: true, validate: false
  has_many :countries,
    -> { where(location_type: "country").order(:name) },
    through: :organizations_countries,
    source: :country
  belongs_to :gma_reviewed_by, class_name: "User", optional: true
  has_one_attached :logo

  GMA_MEMBERSHIPS = %w[none member national_chapter].freeze
  GMA_STATUSES = %w[unverified pending verified rejected].freeze
  GMA_CLAIMS = %w[member national_chapter].freeze
  GMA_REVIEW_DECISIONS = {
    "verify" => "verified",
    "reject" => "rejected"
  }.freeze
  GMA_QUEUE_STATUSES = %w[pending verified rejected].freeze
  PUBLIC_GMA_LABEL = "GMA member"

  validates :organization_name, presence: true
  validates :gma_membership, inclusion: {in: GMA_MEMBERSHIPS}
  validates :gma_status, inclusion: {in: GMA_STATUSES}
  validate :country_location_ids_must_reference_countries
  validate :logo_upload_must_be_valid

  before_validation :apply_gma_claim

  scope :alphabetical, -> {
    order(Arel.sql("LOWER(organizations.organization_name) ASC, organizations.id ASC"))
  }
  scope :name_contains, ->(query) {
    escaped = Organization.sanitize_sql_like(query.to_s.strip)
    where("organizations.organization_name ILIKE ?", "%#{escaped}%")
  }
  scope :in_region, ->(region) {
    matches = Organization.with_country_regions.where("LOWER(country_regions.region) = ?", region.to_s.strip.downcase)
    where(id: matches.select(:id))
  }
  scope :in_country, ->(iso) {
    matches = Organization.with_countries.where("UPPER(locations.iso) = ?", iso.to_s.strip.upcase)
    where(id: matches.select(:id))
  }
  scope :with_countries, -> {
    joins("INNER JOIN organizations_countries ON organizations_countries.organization_id = organizations.id")
      .joins("INNER JOIN locations ON locations.location_id = organizations_countries.location_id AND locations.location_type = 'country'")
  }
  scope :with_country_regions, -> {
    with_countries.joins("INNER JOIN country_regions ON country_regions.iso3 = UPPER(locations.iso)")
  }
  scope :gma_queue, ->(status) { where(gma_status: status, gma_membership: GMA_CLAIMS) }

  SUGGESTED_LIMIT = 5

  def self.suggested_for(user)
    domain = PublicEmailDomains.domain_from(user&.email)
    return none if domain.blank? || PublicEmailDomains.public?(domain)

    scope = all
    member_ids = user.organization_ids
    scope = scope.where.not(id: member_ids) if member_ids.any?

    scope
      .joins(:users)
      .where("LOWER(SPLIT_PART(users.email, '@', 2)) = ?", domain)
      .group("organizations.id")
      .select("organizations.*, COUNT(DISTINCT users.id) AS matching_members_count")
      .order(Arel.sql("matching_members_count DESC, LOWER(organizations.organization_name) ASC, organizations.id ASC"))
      .limit(SUGGESTED_LIMIT)
      .preload(:countries, logo_attachment: :blob)
  end

  def country_location_ids
    organizations_countries.reject(&:marked_for_destruction?).map(&:location_id)
  end

  def country_location_ids=(ids)
    normalized = Array(ids).map { |id| id.to_s.strip }.reject(&:empty?).uniq
    organizations_countries.each(&:mark_for_destruction)
    normalized.each { |location_id| organizations_countries.build(location_id: location_id) }
  end

  def self.with_role_for(user)
    join_sql = sanitize_sql_array([<<~SQL.squish, user.id])
      LEFT OUTER JOIN organizations_users
        ON organizations_users.organization_id = organizations.id
       AND organizations_users.user_id = ?
    SQL
    joins(join_sql).select("organizations.*, organizations_users.role")
  end

  def acknowledged_admins
    OrganizationsUsers.joins(:user)
      .includes(:user)
      .where(organization_id: id, role: "org-admin")
      .where.not(admin_name_acknowledged_at: nil)
      .order(Arel.sql("LOWER(users.name) ASC, users.id ASC"))
  end

  def regions
    isos = countries.filter_map { |country| country.iso&.upcase }
    return [] if isos.empty?

    CountryRegion.where(iso3: isos).distinct.order(:region).pluck(:region)
  end

  def review_gma_membership!(decision, reviewer:, reason: nil)
    status = GMA_REVIEW_DECISIONS[decision]
    return false unless status

    with_lock(requires_new: true) do
      next false unless gma_status == "pending" && GMA_CLAIMS.include?(gma_membership)

      @reviewing_gma_membership = true
      update!(
        gma_status: status,
        gma_reviewed_by: reviewer,
        gma_reviewed_at: Time.current,
        gma_review_reason: reason.to_s.strip.presence
      )
      true
    end
  ensure
    @reviewing_gma_membership = false
  end

  def attach_logo(upload)
    prepared = OrganizationLogo.prepare(upload)
    unless prepared.ok?
      @logo_upload_error = prepared.error
      errors.add(:logo, prepared.error)
      return false
    end

    @logo_upload_error = nil
    self.logo = prepared.attachable
    return true if new_record?

    save(validate: false)
  end

  def gma_representation_for(user)
    if gma_claim_visible_to?(user)
      {
        gma_membership: gma_membership,
        gma_status: gma_status,
        gma_chapter_name: gma_chapter_name
      }
    elsif gma_status == "verified" && GMA_CLAIMS.include?(gma_membership)
      {gma_member: PUBLIC_GMA_LABEL}
    else
      {}
    end
  end

  private

  def apply_gma_claim
    self.gma_chapter_name = if gma_membership == "national_chapter"
      gma_chapter_name.to_s.strip.presence
    end
    return if @reviewing_gma_membership

    if gma_membership == "none"
      self.gma_status = "unverified"
      clear_gma_review
    elsif GMA_CLAIMS.include?(gma_membership) && gma_claim_changed?
      self.gma_status = "pending"
      clear_gma_review
    end
  end

  def clear_gma_review
    self.gma_reviewed_by = nil
    self.gma_reviewed_at = nil
    self.gma_review_reason = nil
  end

  def gma_claim_changed?
    gma_membership_changed? || gma_chapter_name_changed?
  end

  def gma_claim_visible_to?(user)
    return false if user.nil?
    return self[:role].present? if has_attribute?(:role)

    users.exists?(user.id)
  end

  def logo_upload_must_be_valid
    errors.add(:logo, @logo_upload_error) if @logo_upload_error.present?
  end

  def country_location_ids_must_reference_countries
    ids = country_location_ids
    if ids.empty?
      errors.add(:country_location_ids, "must include at least one country")
      return
    end

    found = Location.unscoped.where(location_id: ids, location_type: "country").pluck(:location_id)
    return if (ids - found).empty?

    errors.add(:country_location_ids, "must be country locations")
  end
end
