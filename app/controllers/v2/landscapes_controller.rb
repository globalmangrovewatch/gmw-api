class V2::LandscapesController < MrttApiController
    def index
        # admin can list all landscape record
        # org member can only list landscapes that is associated to the org they are member of
        @landscapes = current_user.is_admin ? Landscape.all :
            (
                organization_ids = current_user.organization_ids
                Landscape.joins(:organizations).where("organization_id in (%s)" % organization_ids.join(","))
            )
    end

    def show
        landscape = Landscape.find(params[:id])
        organization_ids = landscape.organization_ids

        # admin and any org member can show landscape record
        if current_user.is_admin || current_user.is_member_of_any(organization_ids)
            @landscape = Landscape.find(params[:id])
            where_clause = "landscapes_organizations.landscape_id = %s" % @landscape.id.to_s
            @organizations = Organization.joins(:landscapes_organizations).where(where_clause)
        else
            insufficient_privilege && return
        end
    end

    def create
        organization_ids = params[:organizations]
        organizations_exists(organization_ids)

        # admin and any org member can create landscape record
        if current_user.is_admin || current_user.is_member_of_all(organization_ids)
            @landscape = Landscape.create(landscape_params)
            associate_organizations(@landscape, organization_ids)
        else
            insufficient_privilege && return
        end
    end

    def update
        @landscape = Landscape.find(params[:id])
        organization_ids = params[:organizations]
        organizations_exists(organization_ids)

        # admin and any org member can update landscape record
        if current_user.is_admin || current_user.is_member_of_all(organization_ids)
            @landscape.update(landscape_params)
            associate_organizations(@landscape, organizations)
        else
            insufficient_privilege && return
        end
    end

    def destroy
        @landscape = Landscape.find(params[:id])
        organization_ids = @landscape.organization_ids

        # admin and org-admin can delete landscape record
        if current_user.is_admin || current_user.is_org_admin_of_all(organization_ids)
            @landscape.destroy
        else
            insufficient_privilege && return
        end
    end

    private

    def organizations_exists(organizations)
        organizations.each do |org|
            @organization = Organization.find(org)
        end
    end

    def associate_organizations(landscape, organizations)
        @landscapes_organizations_by_landscape_id = LandscapesOrganizations.where("landscape_id = ?", landscape.id)
        if @landscapes_organizations_by_landscape_id
            @landscapes_organizations_by_landscape_id.delete_all
        end
        organizations.each do |org|
            LandscapesOrganizations.create(landscape_id: landscape.id, organization_id: org)
        end
    end

    def landscape_params
        params.require(:landscape).permit(:landscape_name, :organizations)
    end
end
