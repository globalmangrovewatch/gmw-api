class V2::GmaOrganizationsController < MrttApiController
  before_action :require_gma_validator

  def index
    status = params[:status].to_s.strip.downcase.presence || "pending"
    unless Organization::GMA_QUEUE_STATUSES.include?(status)
      render json: {errors: {status: ["must be pending, verified, or rejected"]}}, status: :unprocessable_entity
      return
    end

    @organizations = Organization.gma_queue(status).includes(:countries).order(:created_at, :id)
  end

  def update
    organization = Organization.find(params[:id])
    decision = params[:decision].to_s.strip.downcase
    unless Organization::GMA_REVIEW_DECISIONS.key?(decision)
      render json: {errors: {decision: ["must be verify or reject"]}}, status: :unprocessable_entity
      return
    end

    begin
      reviewed = organization.review_gma_membership!(decision, reviewer: current_user, reason: params[:reason])
    rescue ActiveRecord::RecordInvalid
      render json: {errors: organization.errors.to_hash}, status: :unprocessable_entity
      return
    end

    unless reviewed
      render json: {errors: {gma_status: ["must be a pending claim"]}}, status: :unprocessable_entity
      return
    end

    enqueue_decision_emails(organization)
    @organization = organization
    render :show
  end

  private

  def require_gma_validator
    insufficient_privilege unless current_user.gma_validator?
  end

  def enqueue_decision_emails(organization)
    admin_ids = OrganizationsUsers.where(organization_id: organization.id, role: "org-admin").pluck(:user_id)
    admin_ids.each do |admin_id|
      GmaMembershipReviewNotificationJob.perform_later(organization.id, admin_id)
    end
  end
end
