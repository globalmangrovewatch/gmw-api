class V2::OrganizationsController < MrttApiController
    def index
        @organizations = Organization.all
    end

    def show
        @organization = Organization.find(params[:id])
    end

    def create
        @organization = Organization.create(organization_params)
    end

    def update
        @organization = Organization.find(params[:id])
        @organization.update(organization_params)
    end

    def destroy
        @organization = Organization.find(params[:id])
        @organization.destroy
    end

    def organization_params
        params.require(:organization).permit(:organization_name)
    end
end
