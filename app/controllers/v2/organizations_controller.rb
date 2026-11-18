class V2::OrganizationsController < MrttApiController
  DEFAULT_PER_PAGE = 25

  def index
    return assign_organizations_by_membership if controller_path.start_with?("v3/")

    organizations = Organization.with_role_for(current_user).alphabetical
    organizations = organizations.name_contains(search_query) if search_query
    organizations = organizations.in_region(region_param) if region_param
    organizations = organizations.in_country(country_param) if country_param

    @page = page_param
    @per_page = per_page_param
    @total = organizations.unscope(:select, :order).count
    @organizations = organizations.offset((@page - 1) * @per_page).limit(@per_page)
    render :filtered_index
  end

  def suggested
    @organizations = Organization.suggested_for(current_user)
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.validate
    if enforce_admin_name_acknowledgement? && !admin_name_acknowledged?
      @organization.errors.add(:admin_name_acknowledged, "must be accepted")
    end
    if @organization.errors.any?
      render json: {errors: @organization.errors.to_hash}, status: :unprocessable_entity
      return
    end

    Organization.transaction do
      @organization.save!
      add_or_update_user_helper({
        organization_id: @organization.id,
        email: current_user.email,
        role: "org-admin"
      })
    end
  end

  def update
    @organization = Organization.find(params[:id])
    if !(current_user.is_admin || current_user.is_org_admin(@organization.id))
      insufficient_privilege && return
    end
    return if block_unacknowledged_org_admin!(@organization.id)
    unless @organization.update(organization_params)
      render json: {errors: @organization.errors.to_hash}, status: :unprocessable_entity
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    if !(current_user.is_admin || current_user.is_org_admin(@organization.id))
      insufficient_privilege && return
    end
    return if block_unacknowledged_org_admin!(@organization.id)
    @organization.destroy
  end

  def get_users
    organization = Organization.find(params[:organization_id])
    if !(current_user.is_admin || current_user.is_org_admin(organization.id))
      insufficient_privilege && return
    end
    return if block_unacknowledged_org_admin!(organization.id)
    @users = organization.users.select("users.*, organizations_users.role")
  end

  def get_user
    organization = Organization.find(params[:organization_id])
    user = User.find_by_email!(params[:email])
    if !(current_user.is_admin || current_user.is_org_admin(organization.id))
      insufficient_privilege && return
    end
    return if block_unacknowledged_org_admin!(organization.id)
    _user_id = params[:user_id]
    @user = organization.users.where('"organizations_users"."user_id"=%s' % user.id).select("users.*, organizations_users.role").first
  end

  def remove_user
    organization = Organization.find(params[:organization_id])
    if !(current_user.is_admin || current_user.is_org_admin(organization.id))
      insufficient_privilege && return
    end
    return if block_unacknowledged_org_admin!(organization.id)
    user = User.find_by_email!(params[:email])
    @organization_user = OrganizationsUsers.where(organization_id: organization.id, user_id: user.id).first
    @organization_user.destroy
  end

  def add_user
    organization = Organization.find(params[:organization_id])
    if !(current_user.is_admin || current_user.is_org_admin(organization.id))
      insufficient_privilege && return
    end
    return if block_unacknowledged_org_admin!(organization.id)
    return if reject_admin_role_without_acknowledgement!(params[:role])
    add_or_update_user_helper(params)
  end

  def update_user
    organization = Organization.find(params[:organization_id])
    if !(current_user.is_admin || current_user.is_org_admin(organization.id))
      insufficient_privilege && return
    end
    if params[:email] == current_user.email
      forbidden_role_change && return
    end
    return if block_unacknowledged_org_admin!(organization.id)
    return if reject_admin_role_without_acknowledgement!(params[:role])
    add_or_update_user_helper(params)
  end

  def acknowledge_admin_name
    @organization = Organization.find(params[:organization_id])
    membership = OrganizationsUsers.find_by(organization_id: @organization.id, user_id: current_user.id)
    unless membership&.role == "org-admin"
      render json: {errors: {role: ["must be an organization admin"]}}, status: :unprocessable_entity
      return
    end

    case admin_name_acknowledgement
    when :accepted
      membership.update!(admin_name_acknowledged_at: Time.current) if membership.admin_name_acknowledged_at.blank?
      render :show
    when :declined
      membership.update!(role: "org-user", admin_name_acknowledged_at: nil)
      render :show
    else
      render json: {errors: {admin_name_acknowledged: ["must be accepted"]}}, status: :unprocessable_entity
    end
  end

  private

  def add_or_update_user_helper(request_params)
    organization_id = request_params[:organization_id]
    email = request_params[:email]
    role = request_params[:role]
    organization = Organization.find(organization_id)

    user = User.find_by_email!(email)
    organization_user = OrganizationsUsers.where(organization_id: organization.id, user_id: user.id).first
    attributes = membership_attributes_for(role, organization_user)
    if organization_user.nil?
      OrganizationsUsers.create(attributes.merge(organization_id: organization.id, user_id: user.id))
    else
      organization_user.update(attributes)
    end

    where_clause = "organizations.id = %s and users.id = %s" % [organization.id, user.id]
    @user = Organization.joins(:users).where(where_clause).select("users.*, organizations_users.role").first
  end

  def membership_attributes_for(role, organization_user)
    attributes = {role: role}
    if role.to_s == "org-admin" && enforce_admin_name_acknowledgement?
      attributes[:admin_name_acknowledged_at] = organization_user&.admin_name_acknowledged_at || Time.current
    elsif role.to_s != "org-admin"
      attributes[:admin_name_acknowledged_at] = nil
    end
    attributes
  end

  def reject_admin_role_without_acknowledgement!(role)
    return false unless enforce_admin_name_acknowledgement?
    return false unless role.to_s == "org-admin"
    return false if admin_name_acknowledged?

    render json: {errors: {admin_name_acknowledged: ["must be accepted"]}}, status: :unprocessable_entity
    true
  end

  def organization_user_params
    params.except(:format, :organization).permit(:organization_id, :user_id, :role, :email)
  end

  def organization_params
    params.except(:format, :organization).permit(:organization_name, :id, country_location_ids: [])
  end

  def assign_organizations_by_membership
    @own_organizations = Organization.joins(:organizations_users)
      .select("organizations.*, organizations_users.role")
      .where("organizations_users.user_id=%s" % current_user.id)
    where_clause = "organizations.id not in (select organization_id " \
                   "from organizations_users where user_id=%s)" % current_user.id
    @other_organizations = Organization
      .select("organizations.*, null as role")
      .where(where_clause)
  end

  def search_query
    params[:q].to_s.strip.presence
  end

  def region_param
    params[:region].to_s.strip.presence
  end

  def country_param
    params[:country].to_s.strip.presence
  end

  def page_param
    value = params[:page].to_i
    value.positive? ? value : 1
  end

  def per_page_param
    value = params[:per_page].to_i
    value.positive? ? value : DEFAULT_PER_PAGE
  end
end
