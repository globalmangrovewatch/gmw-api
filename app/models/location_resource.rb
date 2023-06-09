class LocationResource < ApplicationRecord
  belongs_to :location

  validates_presence_of :name
end
