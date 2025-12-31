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

  scope :admins, -> { where(admin: true) }
  scope :subscribed_to_alerts, -> { where(subscribed_to_location_alerts: true) }
  scope :subscribed_to_newsletter, -> { where(subscribed_to_newsletter: true) }

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

  def alertable_locations
    return UserLocation.none unless subscribed_to_location_alerts
    user_locations.where(alerts_enabled: true)
  end

  def notification_preferences
    {
      location_alerts: subscribed_to_location_alerts,
      newsletter: subscribed_to_newsletter,
      platform_updates: subscribed_to_platform_updates
    }
  end

  def update_notification_preferences(preferences)
    updates = {}
    updates[:subscribed_to_location_alerts] = preferences[:location_alerts] if preferences.key?(:location_alerts)
    updates[:subscribed_to_newsletter] = preferences[:newsletter] if preferences.key?(:newsletter)
    updates[:subscribed_to_platform_updates] = preferences[:platform_updates] if preferences.key?(:platform_updates)
    update(updates) if updates.present?
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
