require "active_support/concern"

module NumberFormat
  extend ActiveSupport::Concern

  class_methods do
    def comma_conversion(value)
      value = value.tr(",", ".") if value.is_a?(String)
      value
    end
  end
end
