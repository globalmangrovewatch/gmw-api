class User < ApplicationRecord
  devise :database_authenticatable,
    :jwt_authenticatable,
    :registerable,
    :confirmable,
    :recoverable,
    jwt_revocation_strategy: JwtDenylist
  has_and_belongs_to_many :organizations
  has_many :user_locations, dependent: :destroy
  has_many :saved_locations, through: :user_locations, source: :location

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
    organization_ids.include?(organization_id)
  end

  def is_member_of_any(organization_ids)
    !(self.organization_ids & organization_ids).empty?
  end

  def is_member_of_all(organization_ids)
    common = (self.organization_ids & organization_ids)
    organization_ids.sort == common.sort
  end

  def is_org_user(organization_id)
    get_one_organization_user(organization_id)&.role.to_s == "org-user"
  end

  def is_org_admin(organization_id)
    get_one_organization_user(organization_id)&.role.to_s == "org-admin"
  end

  def is_org_admin_of_all(organization_ids)
    result = get_many_organization_user(organization_ids)
    result.each do |item|
      return false if item.role != "org-admin"
    end
    result.present?
  end

  def is_admin
    admin
  end

  def roles
    get_all_org_roles
  end

  private

  def get_one_organization_user(organization_id)
    organizations.joins(:organizations_users)
      .select("organizations_users.*").find_by_id(organization_id)
  end

  def get_many_organization_user(organization_ids)
    organization_ids.append(0)
    where_clause = "organizations_users.organization_id in (%s)" % (organization_ids + [0]).join(",")
    organizations.joins(:organizations_users)
      .select("organizations_users.*").where(where_clause)
  end

  def get_all_org_roles
    h = organizations.joins(:organizations_users)
      .select("organizations_users.*").map { |i| [i.organization_id, i.role] }.to_h
    admin ? h.merge({"*": "admin"}) : h
  end
end
