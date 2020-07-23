class LocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :location_type, :iso, :bounds, :area_m2, :perimeter_m, :location_id, :coast_length_m, :geometry

  has_many :mangrove_datum
end
