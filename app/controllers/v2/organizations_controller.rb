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
    unless @organization.save
      render json: {errors: @organization.errors.to_hash}, status: :unprocessable_entity
      return
    end

    add_or_update_user_helper({
      organization_id: @organization.id,
      email: current_user.email,
      role: "org-admin"
    })
  end

  def update
    @organization = Organization.find(params[:id])
    if !(current_user.is_admin || current_user.is_org_admin(@organization.id))
      insufficient_privilege && return
    end
    unless @organization.update(organization_params)
      render json: {errors: @organization.errors.to_hash}, status: :unprocessable_entity
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    if !(current_user.is_admin || current_user.is_org_admin(@organization.id))
      insufficient_privilege && return
    end
    @organization.destroy
  end

  def get_users
    organization = Organization.find(params[:organization_id])
    if !(current_user.is_admin || current_user.is_org_admin(organization.id))
      insufficient_privilege && return
    end
    @users = organization.users.select("users.*, organizations_users.role")
  end

  def get_user
    organization = Organization.find(params[:organization_id])
    user = User.find_by_email!(params[:email])
    if !(current_user.is_admin || current_user.is_org_admin(organization.id))
      insufficient_privilege && return
    end
    _user_id = params[:user_id]
    @user = organization.users.where('"organizations_users"."user_id"=%s' % user.id).select("users.*, organizations_users.role").first
  end

  def remove_user
    organization = Organization.find(params[:organization_id])
    if !(current_user.is_admin || current_user.is_org_admin(organization.id))
      insufficient_privilege && return
    end
    user = User.find_by_email!(params[:email])
    @organization_user = OrganizationsUsers.where(organization_id: organization.id, user_id: user.id).first
    @organization_user.destroy
  end

  def add_user
    organization = Organization.find(params[:organization_id])
    if !(current_user.is_admin || current_user.is_org_admin(organization.id))
      insufficient_privilege && return
    end
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
    add_or_update_user_helper(params)
  end

  private

  def add_or_update_user_helper(params)
    organization_id = params[:organization_id]
    email = params[:email]
    role = params[:role]
    organization = Organization.find(organization_id)

    user = User.find_by_email!(email)
    organization_user = OrganizationsUsers.where(organization_id: organization.id, user_id: user.id).first
    if organization_user.nil?
      params = {
        organization_id: organization.id,
        user_id: user.id,
        role: role
      }
      _organization_user = OrganizationsUsers.create(params)
    else
      organization_user.update(role: role)
    end

    where_clause = "organizations.id = %s and users.id = %s" % [organization.id, user.id]
    @user = Organization.joins(:users).where(where_clause).select("users.*, organizations_users.role").first
  end

  private

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
