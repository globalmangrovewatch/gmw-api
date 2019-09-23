class LocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :location_type, :iso, :bounds, :area_m2, :perimeter_m, :coast_length_m, :location_id

  def bounds
    JSON.parse self.object.bounds if self.object.bounds
  end

  has_many :mangrove_datum
end
