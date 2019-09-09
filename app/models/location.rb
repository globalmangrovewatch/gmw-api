class Location < ApplicationRecord
  require 'csv'

  before_destroy :destroy_mangrove_data

  # model association
  has_many :mangrove_datum, dependent: :destroy
  # validations
  validates_presence_of :name, :location_type, :iso

  def self.worldwide
    self.find_by(location_type: 'worldwide')
  end

  def self.rank_by_mangrove_data_column(column_name, start_date = '1996', end_date = '2015', limit = '5')
    result = self.includes(:mangrove_datum)
      .where.not("mangrove_data.#{column_name} IS NULL")
      .where.not(location_type: 'worldwide')
      .where("mangrove_data.date >= ? AND mangrove_data.date <= ?", Date.strptime(start_date, '%Y'), Date.strptime(end_date, '%Y'))
      .order("mangrove_data.#{column_name} DESC")

    result.slice(0, limit.to_i)
  end

  def self.import(import_params)
    CSV.foreach(import_params[:file].path, headers: false, col_sep: ';').with_index do |row, i|
      if (i > 0)
        location_hash = Location.new
        location_hash.name = row[0]
        location_hash.location_type = row[1]
        location_hash.iso = row[2]
        location_hash.bounds = row[3]
        location_hash.geometry = row[4]
        location_hash.area_m2 = row[5]
        location_hash.perimeter_m = row[6]
        location_hash.coast_length_m = row[7]
        location_hash.location_id = row[8]
        location_hash.save!
      end
    end
  end

  def self.dates_with_data(column_name)
    if column_name
      self.joins(:mangrove_datum).select('mangrove_data.date').where.not("mangrove_data.#{column_name} IS NULL").group('mangrove_data.date')
    else
      self.joins(:mangrove_datum).select('mangrove_data.date').group('mangrove_data.date')
    end    
  end

  private

   def destroy_mangrove_data
     self.mangrove_datum.destroy_all
   end
end
