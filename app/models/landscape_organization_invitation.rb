class LandscapeOrganizationInvitation < ApplicationRecord
  STATUSES = %w[pending accepted declined].freeze
  DECISIONS = %w[accepted declined].freeze
  SITE_DATA_NOTICE = "Accepting gives every member of your organization access to this landscape's site data.".freeze

  belongs_to :landscape
  belongs_to :inviting_organization, class_name: "Organization"
  belongs_to :invited_organization, class_name: "Organization"
  belongs_to :invited_by, class_name: "User"
  belongs_to :responded_by, class_name: "User", optional: true

  validates :status, inclusion: {in: STATUSES}
  validate :organizations_differ, on: :create
  validate :inviting_organization_in_landscape, on: :create
  validate :invited_organization_not_in_landscape, on: :create
  validate :inviter_is_not_a_member_of_invited_organization, on: :create
  validate :no_other_pending_invitation, on: :create

  scope :pending, -> { where(status: "pending") }

  def pending?
    status == "pending"
  end

  def inviter_name
    raw_name = invited_by&.name.to_s.strip
    return if raw_name.blank? || raw_name.include?("@")

    raw_name
  end

  def respond(decision, responder:, site_data_acknowledged:)
    with_lock(requires_new: true) do
      next false unless pending? && DECISIONS.include?(decision)
      next false if decision == "accepted" && !site_data_acknowledged

      now = Time.current
      update!(
        status: decision,
        responded_by: responder,
        responded_at: now,
        site_data_acknowledged_at: (decision == "accepted") ? now : nil
      )
      link_organization! if decision == "accepted"
      true
    end
  end

  private

  def link_organization!
    return if LandscapesOrganizations.exists?(landscape_id: landscape_id, organization_id: invited_organization_id)

    LandscapesOrganizations.create!(landscape_id: landscape_id, organization_id: invited_organization_id)
  end

  def organizations_differ
    return if inviting_organization_id.blank? || invited_organization_id.blank?
    return unless inviting_organization_id == invited_organization_id

    errors.add(:invited_organization, "must be a different organization")
  end

  def inviting_organization_in_landscape
    return if landscape_id.blank? || inviting_organization_id.blank?
    return if LandscapesOrganizations.exists?(landscape_id: landscape_id, organization_id: inviting_organization_id)

    errors.add(:inviting_organization, "must already belong to this landscape")
  end

  def invited_organization_not_in_landscape
    return if landscape_id.blank? || invited_organization_id.blank?
    return unless LandscapesOrganizations.exists?(landscape_id: landscape_id, organization_id: invited_organization_id)

    errors.add(:invited_organization, "is already part of this landscape")
  end

  def inviter_is_not_a_member_of_invited_organization
    return if invited_by_id.blank? || invited_organization_id.blank?
    return unless OrganizationsUsers.exists?(organization_id: invited_organization_id, user_id: invited_by_id)

    errors.add(:invited_organization, "can be linked directly")
  end

  def no_other_pending_invitation
    return if landscape_id.blank? || invited_organization_id.blank?
    return unless self.class.pending.where(landscape_id: landscape_id, invited_organization_id: invited_organization_id).exists?

    errors.add(:invited_organization, "already has a pending invitation")
  end
end
