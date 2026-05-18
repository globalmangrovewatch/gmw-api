class LocationAttribute < ApplicationRecord
  belongs_to :location

  LEGAL_STATUS_OPTIONS = %w[mangrove forest].freeze

  enum :legal_status, {mangrove: "mangrove", forest: "forest"}, prefix: true

  def self.legal_status_options
    LEGAL_STATUS_OPTIONS
  end
end
