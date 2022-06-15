class V2::LandscapesController < MrttApiController
    def index
        @landscapes = Landscape.all
    end

    def show
        @landscape = Landscape.find(params[:id])
        join_clause = "inner join landscapes_organizations on
            landscapes_organizations.organization_id = organizations.id
            and landscapes_organizations.landscape_id = %s" % [@landscape.id]
        @organizations = Organization.joins(join_clause)
    end

    def create
        organizations = params[:organizations]
        organizations_exists(organizations)
        @landscape = Landscape.create(landscape_params)
        associate_organizations(@landscape, organizations)
    end

    def update
        organizations = params[:organizations]
        organizations_exists(organizations)
        @landscape = Landscape.find(params[:id])
        @landscape.update(landscape_params)
        associate_organizations(@landscape, organizations)
    end

    def destroy
        @landscape = Landscape.find(params[:id])
        @landscape.destroy
    end

    def organizations_exists(organizations)
        organizations.each do |org|
            @organization = Organization.find(org)
        end
    end

    def associate_organizations(landscape, organizations)
        @landscapes_organizations_by_landscape_id = LandscapesOrganizations.find_by(landscape_id: landscape.id)
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
