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

    def get_users
        @users = Organization.find(params[:organization_id]).users.select("users.*, organizations_users.role")
    end

    def add_or_update_user
        current_user_is_admin = current_user.admin
        insufficient_privilege && return if !current_user_is_admin 
        
        organization = Organization.find(params[:organization_id])
        user = User.find(params[:user_id])

        organization_user = OrganizationsUsers.where(organization_id: params[:organization_id], user_id: params[:user_id]).first
        
        if organization_user == nil
            organization_user = OrganizationsUsers.create(organization_user_params)
        else
            organization_user.update(role: params[:role])
        end

        render json: {
            message: "%s is now a member of %s with %s role" % [user.name, organization.organization_name, organization_user.role]
        }
    end
    
    def remove_user
        current_user_is_admin = current_user.admin
        insufficient_privilege && return if !current_user_is_admin 

        @organization_user = OrganizationsUsers.where(organization_id: params[:organization_id], user_id: params[:user_id]).first
        @organization_user.destroy
    end

    private

    def organization_user_params
        params.except(:format, :organization).permit(:organization_id, :user_id, :role)
    end

    def organization_params
        params.permit(:organization).require(:organization).permit(:organization_name)
    end

    def insufficient_privilege
        render json: {message: "Insufficient privilege" }, status: :unauthorized
    end
end
