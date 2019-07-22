class MangroveDatum < ApplicationRecord
  # model association
  belongs_to :location
  # validations
  validates_presence_of :date
end
