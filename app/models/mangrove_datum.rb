class MangroveDatum < ApplicationRecord
  include ::NumberFormat

  # model association
  belongs_to :location
  # validations
  validates_presence_of :date

  def self.worldwide
    worldwide = Location.worldwide
    where(location_id: worldwide.id)
    self
  end
end
