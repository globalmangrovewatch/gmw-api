class V2::OrganizationJoinRequestsController < MrttApiController
  def index
    organization = Organization.find(params[:organization_id])
    return unless org_admin?(organization)

    @join_requests = organization.organization_join_requests.pending.includes(:user).order(:created_at, :id)
  end

  def create
    organization = Organization.find(params[:organization_id])
    @join_request = organization.organization_join_requests.new(
      user: current_user,
      message: params[:message].to_s.strip.presence,
      status: "pending"
    )
    if @join_request.save
      enqueue_new_request_emails(@join_request)
      render :show, status: :created
    else
      render json: {errors: @join_request.errors.to_hash}, status: :unprocessable_entity
    end
  end

  def update
    organization = Organization.find(params[:organization_id])
    return unless org_admin?(organization)

    @join_request = organization.organization_join_requests.find(params[:request_id])
    decision = params[:status].to_s
    unless OrganizationJoinRequest::REVIEW_DECISIONS.include?(decision)
      render json: {errors: {status: ["must be approved or rejected"]}}, status: :unprocessable_entity
      return
    end

    begin
      reviewed = @join_request.review(decision, reviewer: current_user)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      render json: {errors: {status: ["could not be updated"]}}, status: :unprocessable_entity
      return
    end

    unless reviewed
      render json: {errors: {status: ["must be a pending request"]}}, status: :unprocessable_entity
      return
    end

    enqueue_decision_email(@join_request)
    render :show
  end

  def mine
    @join_requests = current_user.organization_join_requests.includes(:organization).order(created_at: :desc, id: :desc)
  end

  private

  def org_admin?(organization)
    membership = OrganizationsUsers.find_by(organization_id: organization.id, user_id: current_user.id)
    unless membership&.role == "org-admin"
      insufficient_privilege
      return false
    end

    return true if membership.admin_name_acknowledged_at.present?

    render json: {errors: {admin_name_acknowledged: ["must be accepted"]}}, status: :unprocessable_entity
    false
  end

  def enqueue_new_request_emails(join_request)
    admin_ids = OrganizationsUsers.where(organization_id: join_request.organization_id, role: "org-admin").pluck(:user_id)
    admin_ids.each do |admin_id|
      OrganizationJoinRequestNotificationJob.perform_later(join_request.id, "created", admin_id)
    end
  end

  def enqueue_decision_email(join_request)
    OrganizationJoinRequestNotificationJob.perform_later(join_request.id, "decided", join_request.user_id)
  end
end
