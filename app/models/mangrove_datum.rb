class MangroveDatum < ApplicationRecord
  require 'csv'

  # model association
  belongs_to :location
  # validations
  validates_presence_of :date

  def self.mangrove_coverage
    self.select('date, sum(length_m)').group('date').order('date')
  end

  def self.import(import_params)
    CSV.foreach(import_params[:file].path, headers: true, col_sep: ';') do |row|
      mangrove_datum_hash = Location.new
      mangrove_datum_hash.date = row[0]
      mangrove_datum_hash.gain_m2 = row[1]
      mangrove_datum_hash.loss_m2 = row[2]
      mangrove_datum_hash.length_m = row[3]
      mangrove_datum_hash.area_m2 = row[4]
      mangrove_datum_hash.hmax_m = row[5]
      mangrove_datum_hash.agb_mgha_1 = row[6]
      mangrove_datum_hash.hba_m = row[7]
      mangrove_datum_hash.location_id = row[8]
      mangrove_datum_hash.save!
    end
  end
end
