class V2::OrganizationsController < MrttApiController
    def index
        @own_organizations = Organization.joins(:organizations_users)
            .select("distinct organizations.*, organizations_users.role")
            .where("organizations_users.user_id=%s" % current_user.id)
        where_clause = "organizations.id not in (select organization_id from organizations_users where user_id=%s)" % current_user.id
        @other_organizations = Organization.left_joins(:organizations_users)
            .select("distinct organizations.*, null as role")
            .where(where_clause)
    end

    def show
        @organization = Organization.find(params[:id])
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
        @organization = Organization.find(params[:id])
        if not (current_user.is_admin || current_user.is_org_admin(@organization.id))
            insufficient_privilege && return
        end
        @organization.update(organization_params)
    end

    def destroy
        @organization = Organization.find(params[:id])
        if not (current_user.is_admin || current_user.is_org_admin(@organization.id))
            insufficient_privilege && return
        end
        @organization.destroy
    end

    def get_users
        organization = Organization.find(params[:organization_id])
        if not (current_user.is_admin || current_user.is_org_admin(organization.id))
            insufficient_privilege && return
        end
        @users = organization.users.select("users.*, organizations_users.role")
    end

    def add_or_update_user
        organization = Organization.find(params[:organization_id])
        if not (current_user.is_admin || current_user.is_org_admin(organization.id))
            insufficient_privilege && return
        end
        add_or_update_user_helper(params)
    end

    def remove_user
        organization = Organization.find(params[:organization_id])
        if not (current_user.is_admin || current_user.is_org_admin(organization.id))
            insufficient_privilege && return
        end
        user_id = params[:user_id]
        @organization_user = OrganizationsUsers.where(organization_id: organization.id, user_id: user_id).first
        @organization_user.destroy
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

    def organization_user_params
        params.except(:organization, :format).permit(:organization_id, :user_id, :role)
    end

    def organization_params
        params.except(:organization, :format).permit(:organization_name, :id)
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
        params.except(:format, :organization).permit(:organization_name)
    end
end
