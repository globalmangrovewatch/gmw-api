class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable,
         jwt_revocation_strategy: JwtDenylist
  has_and_belongs_to_many :organizations

  def jwt_payload
    {
      meta: {
        id: id,
        email: email,
        name: name,
        roles: get_all_org_roles
      }
    }
  end

  def is_member(organization_id)
    return get_organization_user(organization_id).present?
  end

  def is_org_user(organization_id)
    return (get_organization_user(organization_id)&.role).to_s == 'org-user'
  end

  def is_org_admin(organization_id)
    return (get_organization_user(organization_id)&.role).to_s == 'org-admin'
  end

  def is_admin
    return self.admin
  end

  def roles
    get_all_org_roles
  end

  private

  def get_organization_user(organization_id)
    self.organizations.joins(:organizations_users)
      .select("organizations_users.role").find_by_id(organization_id)
  end

  def get_all_org_roles
    h = self.organizations.joins(:organizations_users)
      .select("organizations_users.*").map { |i| [i.organization_id, i.role] }.to_h
    self.admin ? h.merge({"*": "admin"}) : h
  end

end