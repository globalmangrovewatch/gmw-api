class MangroveDatum < ApplicationRecord
  require 'csv'

  # model association
  belongs_to :location
  # validations
  validates_presence_of :date

  def self.mangrove_coverage(country = nil, location_id = nil)
    data = self
      .select('date, sum(length_m) as value, \'m\' as unit')
      .group('date')
      .where.not(length_m: nil)
      .order('date')

    if (country || location_id)
      if country
        location = Location.find_by(iso: country, location_type: 'country')
      elsif location_id
        location = Location.find(location_id)
      end

      if location
        data = data.where(location_id: location.id)
      else
        data = nil
      end
    end

    data
  end

  def self.mangrove_net_change(country = nil, location_id = nil)
    data = self
      .select('date, sum(loss_m2) as loss, sum(gain_m2) as gain, (sum(gain_m2) - sum(loss_m2)) net_change, \'m2\' as unit')
      .group('date')
      .where.not(loss_m2: nil)
      .where.not(gain_m2: nil)
      .order('date')

    if (country || location_id)
      if country
        location = Location.find_by(iso: country, location_type: 'country')
      elsif location_id
        location = Location.find(location_id)
      end

      if location
        data = data.where(location_id: location.id)
      else
        data = nil
      end
    end

    data
  end

  def self.import(import_params)
    CSV.foreach(import_params[:file].path, headers: false, col_sep: ';').with_index do |row, i|
      if (i > 0)
        location = Location.find_by(location_id: row[8])

        if (location)
          mangrove_datum_hash = MangroveDatum.new
          mangrove_datum_hash.date = Date.strptime(row[0], '%Y')
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
