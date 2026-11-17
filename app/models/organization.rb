class Organization < ApplicationRecord
  has_and_belongs_to_many :landscapes
  has_and_belongs_to_many :users
  has_many :organizations_countries, dependent: :destroy, autosave: true, validate: false
  has_many :countries,
    -> { where(location_type: "country").order(:name) },
    through: :organizations_countries,
    source: :country

  validates :organization_name, presence: true
  validate :country_location_ids_must_reference_countries

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
      .preload(:countries)
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

  def regions
    isos = countries.filter_map { |country| country.iso&.upcase }
    return [] if isos.empty?

    CountryRegion.where(iso3: isos).distinct.order(:region).pluck(:region)
  end

  private

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
