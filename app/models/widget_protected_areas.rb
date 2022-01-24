class WidgetProtectedAreas < ApplicationRecord
  
  require 'csv'

  
  MangroveAtlasApi::Application.load_tasks

  # model association
  belongs_to :location
  # validations
  validates_presence_of :location_id
  validates_presence_of :year
  validates_presence_of :total_area
  validates_presence_of :protected_area


  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      
      location = Location.find_by(location_id: row['location_id'])

      if (location)
        
        widget_protected_areas_hash = WidgetProtectedAreas.new

        widget_protected_areas_hash.year = row['year']
        widget_protected_areas_hash.total_area = row['total_area']
        widget_protected_areas_hash.protected_area = row['protected_area']
        widget_protected_areas_hash.location_id = row['location_id']

        widget_protected_areas_hash.save!
      end
    end
    return self
  end

end
