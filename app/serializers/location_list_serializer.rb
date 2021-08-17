class LocationListSerializer < ActiveModel::Serializer
  attributes :id, :name, :location_type, :iso, :bounds, :area_m2, :perimeter_m, :coast_length_m, :location_id
end
