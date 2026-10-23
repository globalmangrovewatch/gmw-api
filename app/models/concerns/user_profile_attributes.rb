module UserProfileAttributes
  extend ActiveSupport::Concern

  BASEMAPS = %w[light dark satellite].freeze

  included do
    validate :validate_user_roles
    validate :validate_user_role_other
    validate :validate_settings
    before_validation :normalize_user_roles
    before_validation :clear_user_role_other_unless_other_selected
  end

  def profile_attributes
    {
      name: name,
      email: email,
      organization: organization,
      user_roles: user_roles,
      user_role_other: user_role_other,
      settings: settings
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

  def validate_settings
    return if settings.nil?

    unless settings.is_a?(Hash)
      errors.add(:settings, "must be an object")
      return
    end

    config = settings.with_indifferent_access
    validate_basemap(config)
    validate_bounds(config)
    validate_widgets(config)
    validate_layers(config)
  end

  def validate_basemap(config)
    return unless config.key?(:basemap)
    return if BASEMAPS.include?(config[:basemap])

    errors.add(:settings, "basemap must be one of: #{BASEMAPS.join(", ")}")
  end

  def validate_bounds(config)
    return unless config.key?(:bounds)

    bounds = config[:bounds]
    pairs_ok = bounds.is_a?(Array) && bounds.length == 2 && bounds.all? { |pair| coordinate_pair?(pair) }
    ranges_ok = pairs_ok &&
      longitude?(bounds[0][0]) && latitude?(bounds[0][1]) &&
      longitude?(bounds[1][0]) && latitude?(bounds[1][1])
    return if ranges_ok

    errors.add(:settings, "bounds must be [[west, south], [east, north]]")
  end

  def validate_widgets(config)
    return unless config.key?(:widgets)

    widgets = config[:widgets]
    return if widgets.is_a?(Array) && widgets.all? { |widget| widget.is_a?(String) }

    errors.add(:settings, "widgets must be an array of strings")
  end

  def validate_layers(config)
    return unless config.key?(:layers)

    layers = config[:layers]
    unless layers.is_a?(Array)
      errors.add(:settings, "layers must be an array")
      return
    end

    layers.each do |layer|
      attrs = layer.is_a?(Hash) ? layer.with_indifferent_access : {}
      unless attrs[:id].is_a?(String) && attrs[:id].present?
        errors.add(:settings, "layers must include an id")
        break
      end
      next if opacity?(attrs[:opacity])

      errors.add(:settings, "layers opacity must be a number between 0 and 1")
      break
    end
  end

  def coordinate_pair?(pair)
    pair.is_a?(Array) && pair.length == 2 && pair.all? { |value| value.is_a?(Numeric) }
  end

  def longitude?(value)
    value >= -180 && value <= 180
  end

  def latitude?(value)
    value >= -90 && value <= 90
  end

  def opacity?(value)
    value.is_a?(Numeric) && value >= 0 && value <= 1
  end
end
