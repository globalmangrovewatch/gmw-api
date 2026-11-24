class V2::LandscapesController < MrttApiController
  def index
    # admin can list all landscape record
    # org member can only list landscapes that is associated to the org they are member of
    @landscapes = current_user.is_admin ? Landscape.all :
        (
            organization_ids = current_user.organization_ids
            Landscape.joins(:organizations)
                .select("distinct landscapes.*")
                .where("organization_id in (%s)" % (organization_ids + [0]).join(","))
          )
  end

  def show
    @landscape = Landscape.find(params[:id])
    organization_ids = @landscape.organization_ids

    # only admin and any org member can show landscape record
    if !(current_user.is_admin || current_user.is_member_of_any(organization_ids))
      insufficient_privilege && return
    end

    where_clause = "landscapes_organizations.landscape_id = %s" % @landscape.id.to_s
    @organizations = Organization.joins(:landscapes_organizations).where(where_clause)
  end

  def create
    organization_ids = params[:organizations]
    organizations_exists(organization_ids)

    if replace_all_landscape_organizations?
      # only admin and any org member can create landscape record
      if !(current_user.is_admin || current_user.is_member_of_all(organization_ids))
        insufficient_privilege && return
      end
    else
      return unless organizations_belong_to_current_user!(organization_ids)
    end

    @landscape = Landscape.create(landscape_params)
    associate_organizations(@landscape, organization_ids)
  end

  def update
    @landscape = Landscape.find(params[:id])
    organization_ids = params[:organizations]
    organizations_exists(organization_ids)

    if replace_all_landscape_organizations?
      # only admin and any org member can update landscape record
      if !(current_user.is_admin || current_user.is_member_of_all(organization_ids))
        insufficient_privilege && return
      end

      @landscape.update(landscape_params)
      associate_organizations(@landscape, organization_ids)
    else
      return unless organizations_can_be_linked_directly!(organization_ids)

      @landscape.update(landscape_params)
      sync_member_organizations(@landscape, organization_ids)
    end
  end

  def destroy
    @landscape = Landscape.find(params[:id])
    organization_ids = @landscape.organization_ids

    # only admin and org-admin can delete landscape record
    if !(current_user.is_admin || current_user.is_org_admin_of_all(organization_ids.dup))
      insufficient_privilege && return
    end
    return if block_unacknowledged_org_admin!(organization_ids)

    @landscape.destroy
  end

  private

  def replace_all_landscape_organizations?
    controller_path.start_with?("v3/") || current_user.is_admin
  end

  def organizations_belong_to_current_user!(organization_ids)
    foreign_ids = normalized_organization_ids(organization_ids) - current_user.organization_ids
    return true if foreign_ids.empty?

    render json: {errors: {organizations: ["must be invited"]}}, status: :unprocessable_entity
    false
  end

  def organizations_can_be_linked_directly!(organization_ids)
    ids = normalized_organization_ids(organization_ids)
    new_foreign_ids = (ids - current_user.organization_ids) - @landscape.organization_ids
    return true if new_foreign_ids.empty?

    render json: {errors: {organizations: ["must be invited"]}}, status: :unprocessable_entity
    false
  end

  def normalized_organization_ids(organization_ids)
    Array(organization_ids).map(&:to_i)
  end

  def sync_member_organizations(landscape, organization_ids)
    own_ids = normalized_organization_ids(organization_ids) & current_user.organization_ids
    LandscapesOrganizations.where(landscape_id: landscape.id, organization_id: current_user.organization_ids).delete_all
    own_ids.each do |org_id|
      LandscapesOrganizations.create!(landscape_id: landscape.id, organization_id: org_id)
    end
  end

  def organizations_exists(organizations)
    organizations.each do |org|
      @organization = Organization.find(org)
    end
  end

  def associate_organizations(landscape, organizations)
    @landscapes_organizations_by_landscape_id = LandscapesOrganizations.where("landscape_id = ?", landscape.id)
    @landscapes_organizations_by_landscape_id&.delete_all
    organizations.each do |org|
      LandscapesOrganizations.create(landscape_id: landscape.id, organization_id: org)
    end
  end

  def landscape_params
    params.require(:landscape).permit(:landscape_name, :organizations)
  end
end
