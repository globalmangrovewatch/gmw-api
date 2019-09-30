class MangroveDatum < ApplicationRecord
  require 'csv'

  # model association
  belongs_to :location
  # validations
  validates_presence_of :date

  def self.worldwide
    worldwide = Location.worldwide
    self.where(location_id: worldwide.id)
    self
  end

  def self.rank_by(column_name, start_date = '1996', end_date = '2015', limit = '5')
    self
      .where.not("#{column_name} IS NULL")
      .where("date >= ? AND date <= ?", Date.strptime(start_date, '%Y'), Date.strptime(end_date, '%Y'))
      .order("#{column_name} DESC")
      .limit(limit.to_i)
  end

  def self.dates_with_data(column_name)
    if column_name
      self.select('date').where.not("#{column_name} IS NULL").group('date')
    else
      self.select('date').group('date')
    end
  end

  def self.import(import_params)
    CSV.foreach(import_params[:file].path, headers: true, col_sep: ';').with_index do |row, i|
      if (i > 0)
        location = Location.find_by(location_id: row['location_id'])

        if (location)
          puts location
          mangrove_datum_hash = MangroveDatum.new
          mangrove_datum_hash.date = Date.strptime(row['date'], '%Y-%m-%d')
          mangrove_datum_hash.gain_m2 = row['gain_m2']
          mangrove_datum_hash.loss_m2 = row['loss_m2']
          mangrove_datum_hash.length_m = row['length_m']
          mangrove_datum_hash.area_m2 = row['area_m2']
          mangrove_datum_hash.hmax_m = row['hmax_m']
          mangrove_datum_hash.agb_mgha_1 = row['agb_mgha_1']
          mangrove_datum_hash.hba_m = row['hba_m']
          mangrove_datum_hash.con_hotspot_summary_km2 = row['con_hotspot_summary_km2']
          mangrove_datum_hash.agb_hist_mgha_1 = row['agb_hist_mgha_1']
          mangrove_datum_hash.hba_hist_m = row['hba_hist_m']
          mangrove_datum_hash.hmax_hist_m = row['hmax_hist_m']
          mangrove_datum_hash.location = location
          mangrove_datum_hash.save!
        end
      end
    end
  end
end
