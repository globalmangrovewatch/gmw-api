class MangroveDatum < ApplicationRecord
  require 'csv'

  # model association
  belongs_to :location
  # validations
  validates_presence_of :date

  def self.worldwide
    worldwide = Location.worldwide
    self.where(location_id: worldwide.id)
  end

  def self.import(import_params)
    CSV.foreach(import_params[:file].path, headers: false, col_sep: ';').with_index do |row, i|
      if (i > 0)
        location = Location.find_by(location_id: row[8])

        if (location)
          mangrove_datum_hash = MangroveDatum.new
          mangrove_datum_hash.date = Date.strptime(row[0], '%d/%m/%Y')
          mangrove_datum_hash.gain_m2 = row[1]
          mangrove_datum_hash.loss_m2 = row[2]
          mangrove_datum_hash.length_m = row[3]
          mangrove_datum_hash.area_m2 = row[4]
          mangrove_datum_hash.hmax_m = row[5]
          mangrove_datum_hash.agb_mgha_1 = row[6]
          mangrove_datum_hash.hba_m = row[7]
          mangrove_datum_hash.con_hotspot_summary_km2 = row[9]
          mangrove_datum_hash.location = location
          mangrove_datum_hash.save!
        end
      end
    end
  end
end
