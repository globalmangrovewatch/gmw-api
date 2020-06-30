class Location < ApplicationRecord
  require 'csv'
  require 'rake'

  Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
  MangroveAtlasApi::Application.load_tasks

  before_destroy :destroy_mangrove_data

  # model association
  has_many :mangrove_datum, dependent: :destroy
  # validations
  validates_presence_of :name, :location_type, :iso

  def self.worldwide
    self.find_by(location_type: 'worldwide')
  end

  def self.rank_by_mangrove_data_column(column_name, dir = 'DESC', start_date = '1996', end_date = '2015', location_type = nil, limit = '5')
    data = MangroveDatum.select("location_id, sum(#{column_name}) as #{column_name}")
      .where.not(gain_m2: nil, location_id: Location.worldwide.id)
      .where("date >= ? AND date <= ?", Date.strptime(start_date, '%Y'), Date.strptime(end_date, '%Y'))
      .group(column_name)
      .order("#{column_name} #{dir}")
      .limit(limit)
    
    data = result.where(location_type: location_type) if location_type

    location_ids = data.map { |m| m.location_id }
    
    self.where(id: location_ids).includes(:mangrove_datum)
  end

  def self.import(import_params)
    CSV.foreach(import_params[:file].path, headers: true, col_sep: ';') do |row|
      location_hash = Location.new
      location_hash.name = row['name']
      location_hash.location_type = row['location_type']
      location_hash.iso = row['iso']
      location_hash.bounds = row['bounds']
      location_hash.geometry = row['geometry']
      location_hash.area_m2 = row['area_m2']
      location_hash.perimeter_m = row['perimeter_m']
      location_hash.coast_length_m = row['coast_length_m']
      location_hash.location_id = row['location_id']
      location_hash.save!
    end

    Rake::Task['worldwide:location'].invoke

    return self
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
