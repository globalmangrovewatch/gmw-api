class OrganizationJoinRequestNotificationJob < ApplicationJob
  queue_as :mailers

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(join_request_id, event, recipient_id)
    join_request = OrganizationJoinRequest.includes(:organization, :user).find_by(id: join_request_id)
    recipient = User.find_by(id: recipient_id)
    return if join_request.blank? || recipient.blank? || recipient.email.blank?

    case event
    when "created"
      NotificationMailer.organization_join_request_received(
        recipient_email: recipient.email,
        organization_name: join_request.organization.organization_name,
        requester_name: join_request.requester_name,
        message: join_request.message
      ).deliver_now
    when "decided"
      return unless OrganizationJoinRequest::REVIEW_DECISIONS.include?(join_request.status)

      NotificationMailer.organization_join_request_decided(
        recipient_email: recipient.email,
        organization_name: join_request.organization.organization_name,
        status: join_request.status
      ).deliver_now
    end
  end
end
