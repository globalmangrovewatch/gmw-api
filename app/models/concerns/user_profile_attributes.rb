module UserProfileAttributes
  extend ActiveSupport::Concern

  included do
    validate :validate_user_roles
    validate :validate_user_role_other
    before_validation :normalize_user_roles
    before_validation :clear_user_role_other_unless_other_selected
  end

  def profile_attributes
    {
      name: name,
      email: email,
      organization: organization,
      user_roles: user_roles,
      user_role_other: user_role_other
    }
  end

  private

  def normalize_user_roles
    self.user_roles = Array(user_roles).map(&:to_s).map(&:strip).reject(&:blank?).uniq
  end

  def clear_user_role_other_unless_other_selected
    self.user_role_other = nil unless user_roles.include?(UserProfileRole::OTHER)
  end

  def validate_user_roles
    invalid_roles = user_roles - UserProfileRole::OPTIONS
    return if invalid_roles.empty?

    errors.add(:user_roles, "contains invalid values: #{invalid_roles.join(', ')}")
  end

  def validate_user_role_other
    return unless user_roles.include?(UserProfileRole::OTHER)
    return if user_role_other.present?

    errors.add(:user_role_other, "can't be blank when other is selected")
  end
end
