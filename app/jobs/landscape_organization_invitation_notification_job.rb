class LandscapeOrganizationInvitationNotificationJob < ApplicationJob
  queue_as :mailers

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(invitation_id, event, recipient_id)
    invitation = LandscapeOrganizationInvitation.includes(
      :landscape,
      :inviting_organization,
      :invited_organization,
      :invited_by
    ).find_by(id: invitation_id)
    recipient = User.find_by(id: recipient_id)
    return if invitation.blank? || recipient.blank? || recipient.email.blank?

    case event
    when "created"
      NotificationMailer.landscape_organization_invitation_received(
        recipient_email: recipient.email,
        landscape_name: invitation.landscape.landscape_name,
        inviting_organization_name: invitation.inviting_organization.organization_name,
        invited_organization_name: invitation.invited_organization.organization_name,
        inviter_name: invitation.inviter_name
      ).deliver_now
    when "decided"
      return unless LandscapeOrganizationInvitation::DECISIONS.include?(invitation.status)

      NotificationMailer.landscape_organization_invitation_decided(
        recipient_email: recipient.email,
        landscape_name: invitation.landscape.landscape_name,
        inviting_organization_name: invitation.inviting_organization.organization_name,
        invited_organization_name: invitation.invited_organization.organization_name,
        status: invitation.status
      ).deliver_now
    end
  end
end
