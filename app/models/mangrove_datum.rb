class MangroveDatum < ApplicationRecord
  # model association
  belongs_to :location
  # validations
  validates_presence_of :date

  def self.mangrove_coverage
    self.select('date, sum(length_m)').group('date').order('date')
  end
end
