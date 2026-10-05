class Ability
  include CanCan::Ability

  def initialize(admin_user)
    return unless admin_user

    can :manage, :all
    return if admin_user.super_admin?

    cannot :manage, AdminUser
    cannot [:create, :update, :destroy, :promote_to_admin, :demote_to_user], OrganizationsUsers
    cannot [:promote_member, :demote_member], Organization
  end
end
