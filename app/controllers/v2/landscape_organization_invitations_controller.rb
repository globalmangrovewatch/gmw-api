class V2::LandscapeOrganizationInvitationsController < MrttApiController
  def index
    organization = Organization.find(params[:organization_id])
    return unless acknowledged_org_admin?(organization)

    @invitations = organization.landscape_organization_invitations.pending
      .includes(:landscape, :inviting_organization, :invited_organization, :invited_by)
      .order(:created_at, :id)
  end

  def create
    landscape = Landscape.find(params[:landscape_id])
    inviting_organization = Organization.find(params[:inviting_organization_id])
    return unless landscape_admin?(landscape, inviting_organization)

    invited_organization = Organization.find(params[:invited_organization_id])
    @invitation = landscape.landscape_organization_invitations.new(
      inviting_organization: inviting_organization,
      invited_organization: invited_organization,
      invited_by: current_user,
      status: "pending"
    )

    begin
      saved = @invitation.save
    rescue ActiveRecord::RecordNotUnique
      @invitation.errors.add(:invited_organization, "already has a pending invitation")
      saved = false
    end

    if saved
      enqueue_invitation_emails(@invitation)
      render :show, status: :created
    else
      render json: {errors: @invitation.errors.to_hash}, status: :unprocessable_entity
    end
  end

  def update
    organization = Organization.find(params[:organization_id])
    return unless acknowledged_org_admin?(organization)

    @invitation = organization.landscape_organization_invitations.find(params[:invitation_id])
    decision = params[:status].to_s
    unless LandscapeOrganizationInvitation::DECISIONS.include?(decision)
      render json: {errors: {status: ["must be accepted or declined"]}}, status: :unprocessable_entity
      return
    end

    if decision == "accepted" && !site_data_acknowledged?
      render json: {errors: {site_data_acknowledged: ["must be accepted"]}}, status: :unprocessable_entity
      return
    end

    begin
      responded = @invitation.respond(
        decision,
        responder: current_user,
        site_data_acknowledged: decision == "accepted"
      )
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      render json: {errors: {status: ["could not be updated"]}}, status: :unprocessable_entity
      return
    end

    unless responded
      render json: {errors: {status: ["must be a pending invitation"]}}, status: :unprocessable_entity
      return
    end

    enqueue_decision_emails(@invitation)
    render :show
  end

  private

  def landscape_admin?(landscape, organization)
    membership = OrganizationsUsers.find_by(organization_id: organization.id, user_id: current_user.id)
    unless membership&.role == "org-admin" && landscape.organization_ids.include?(organization.id)
      insufficient_privilege
      return false
    end

    acknowledged_admin_membership?(membership)
  end

  def acknowledged_org_admin?(organization)
    membership = OrganizationsUsers.find_by(organization_id: organization.id, user_id: current_user.id)
    unless membership&.role == "org-admin"
      insufficient_privilege
      return false
    end

    acknowledged_admin_membership?(membership)
  end

  def acknowledged_admin_membership?(membership)
    return true if membership.admin_name_acknowledged_at.present?

    render json: {errors: {admin_name_acknowledged: ["must be accepted"]}}, status: :unprocessable_entity
    false
  end

  def site_data_acknowledged?
    ActiveModel::Type::Boolean.new.cast(params[:site_data_acknowledged]) == true
  end

  def enqueue_invitation_emails(invitation)
    admin_ids = OrganizationsUsers.where(organization_id: invitation.invited_organization_id, role: "org-admin").pluck(:user_id)
    admin_ids.each do |admin_id|
      LandscapeOrganizationInvitationNotificationJob.perform_later(invitation.id, "created", admin_id)
    end
  end

  def enqueue_decision_emails(invitation)
    recipient_ids = OrganizationsUsers.where(organization_id: invitation.invited_organization_id, role: "org-admin").pluck(:user_id)
    recipient_ids << invitation.invited_by_id
    recipient_ids.uniq.each do |recipient_id|
      LandscapeOrganizationInvitationNotificationJob.perform_later(invitation.id, "decided", recipient_id)
    end
  end
end
