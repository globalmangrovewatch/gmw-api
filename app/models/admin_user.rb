class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
    :recoverable, :rememberable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
    :recoverable, :rememberable, :validatable

  enum role: {
    staff: "staff",
    super_admin: "super_admin"
  }

  validate :preserve_last_super_admin, if: :removing_super_admin_role?
  before_destroy :preserve_super_admin_access

  private

  def removing_super_admin_role?
    persisted? && will_save_change_to_role? && role_in_database == "super_admin" && !super_admin?
  end

  def preserve_last_super_admin
    errors.add(:role, "must retain at least one super admin") unless another_super_admin?
  end

  def preserve_super_admin_access
    return unless super_admin? && !another_super_admin?

    errors.add(:base, "At least one super admin must remain")
    throw(:abort)
  end

  def another_super_admin?
    self.class.super_admin.where.not(id: id).exists?
  end
end
