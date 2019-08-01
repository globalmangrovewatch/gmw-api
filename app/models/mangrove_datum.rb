class MangroveDatum < ApplicationRecord
  require 'csv'

  # model association
  belongs_to :location
  # validations
  validates_presence_of :date

  def self.mangrove_coverage(country = nil, location_id = nil)
    if country
      location = Location.find_by(iso: country)
    elsif location_id
      location = Location.find(location_id)
    end



    if location
      data = self
        .select('id, date, sum(length_m)')
        .group('id, date')
        .where.not(length_m: nil)
        .order('date')

      data = data.where(location_id: location.id)
    else
      nil
    end
  end

  def self.import(import_params)
    CSV.foreach(import_params[:file].path, headers: false, col_sep: ';').with_index do |row, i|
      if (i > 0)
        location = Location.find(row[8].to_i)

        if (location)
          mangrove_datum_hash = MangroveDatum.new
          mangrove_datum_hash.date =  Date.strptime(row[0], '%Y')
          mangrove_datum_hash.gain_m2 = row[1]
          mangrove_datum_hash.loss_m2 = row[2]
          mangrove_datum_hash.length_m = row[3]
          mangrove_datum_hash.area_m2 = row[4]
          mangrove_datum_hash.hmax_m = row[5]
          mangrove_datum_hash.agb_mgha_1 = row[6]
          mangrove_datum_hash.hba_m = row[7]
          mangrove_datum_hash.location_id = location.id
          mangrove_datum_hash.save!
        end
      end
    end
  end
end
