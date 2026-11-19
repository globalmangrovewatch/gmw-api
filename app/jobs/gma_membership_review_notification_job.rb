class GmaMembershipReviewNotificationJob < ApplicationJob
  queue_as :mailers

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(organization_id, recipient_id)
    organization = Organization.find_by(id: organization_id)
    recipient = User.find_by(id: recipient_id)
    return if organization.blank? || recipient.blank? || recipient.email.blank?
    return unless Organization::GMA_REVIEW_DECISIONS.value?(organization.gma_status)

    NotificationMailer.gma_membership_reviewed(
      recipient_email: recipient.email,
      organization_name: organization.organization_name,
      status: organization.gma_status,
      reason: organization.gma_review_reason
    ).deliver_now
  end
end
