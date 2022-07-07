class V2::OrganizationsController < MrttApiController
    def index
        @organizations = current_user.is_admin ? Organization.all : current_user.organizations
    end

    def show
        organization_id = params[:id]
        if current_user.is_admin
            @organization = Organization.find(organization_id)
        elsif current_user.is_member(organization_id)
            @organization = current_user.organizations.find(organization_id)
        else
            Organization.find(organization_id) && insufficient_privilege && return
        end
    end

    def create
        @organization = Organization.create(organization_params)
        params = {
            organization_id: @organization.id,
            user_id: current_user.id,
            role: 'org-admin'
        }
        add_or_update_user_helper(params)
    end

    def update
        organization_id = params[:id]
        if current_user.is_admin
            @organization = Organization.find(organization_id)
        elsif current_user.is_org_admin(organization_id)
            @organization = current_user.organizations.find(organization_id)
        else 
            Organization.find(organization_id) && insufficient_privilege && return
        end
        @organization.update(organization_params)
    end

    def destroy
        organization_id = params[:id]
        if current_user.is_admin
            @organization = Organization.find(organization_id)
        elsif current_user.is_org_admin(organization_id)
            @organization = current_user.organizations.find(organization_id)
        else 
            Organization.find(organization_id) && insufficient_privilege && return
        end
        @organization.destroy
    end

    def get_users
        organization_id = params[:organization_id]
        if current_user.is_admin
            @users = Organization.find(organization_id).users.select("users.*, organizations_users.role")
        elsif current_user.is_org_admin(organization_id)
            @users = current_user.organizations.find(organization_id).users.select("users.*, organizations_users.role")
        else 
            Organization.find(organization_id) && insufficient_privilege && return
        end
    end

    def add_or_update_user
        params = organization_user_params
        organization_id = params[:organization_id]
        if current_user.is_admin || current_user.is_org_admin(organization_id)
            add_or_update_user_helper(params)
        else 
            Organization.find(organization_id) && insufficient_privilege && return
        end
   end

    def remove_user
        organization_id = params[:organization_id]
        user_id = params[:user_id]
        if current_user.is_admin || current_user.is_org_admin(organization_id)
            @organization_user = OrganizationsUsers.where(organization_id: organization_id, user_id: user_id).first
            @organization_user.destroy
        else 
            Organization.find(organization_id) && insufficient_privilege && return
        end
    end

    private

    def add_or_update_user_helper(params)
        organization_id = params[:organization_id]
        user_id = params[:user_id]
        role = params[:role]
        organization = Organization.find(organization_id)
        user = User.find(user_id)
        organization_user = OrganizationsUsers.where(organization_id: organization_id, user_id: user_id).first
        if organization_user == nil
            organization_user = OrganizationsUsers.create(params)
        else
            organization_user.update(role: role)
        end
        render json: {
            message: "%s is now a member of %s with %s role" % [user.name, organization.organization_name, organization_user.role]
        }
    end

    def organization_user_params
        params.except(:organization, :format).permit(:organization_id, :user_id, :role)
    end

    def organization_params
        params.except(:organization, :format).permit(:organization_name, :id)
    end
end
