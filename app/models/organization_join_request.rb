class OrganizationJoinRequest < ApplicationRecord
  STATUSES = %w[pending approved rejected].freeze
  REVIEW_DECISIONS = %w[approved rejected].freeze

  belongs_to :organization
  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true

  validates :status, inclusion: {in: STATUSES}
  validate :user_is_not_a_member, on: :create
  validate :no_other_pending_request, on: :create

  scope :pending, -> { where(status: "pending") }

  def pending?
    status == "pending"
  end

  def requester_name
    raw_name = user&.name.to_s.strip
    return if raw_name.blank? || raw_name.include?("@")

    raw_name
  end

  def review(decision, reviewer:)
    with_lock(requires_new: true) do
      next false unless pending? && REVIEW_DECISIONS.include?(decision)

      update!(
        status: decision,
        reviewed_by: reviewer,
        reviewed_at: Time.current
      )
      grant_membership! if decision == "approved"
      true
    end
  end

  private

  def grant_membership!
    return if OrganizationsUsers.exists?(organization_id: organization_id, user_id: user_id)

    OrganizationsUsers.create!(
      organization_id: organization_id,
      user_id: user_id,
      role: "org-user"
    )
  end

  def user_is_not_a_member
    return if user_id.blank? || organization_id.blank?
    return unless OrganizationsUsers.exists?(organization_id: organization_id, user_id: user_id)

    errors.add(:user, "is already a member of this organization")
  end

  def no_other_pending_request
    return if user_id.blank? || organization_id.blank?
    return unless self.class.pending.where(organization_id: organization_id, user_id: user_id).exists?

    errors.add(:user, "already has a pending request")
  end
end
