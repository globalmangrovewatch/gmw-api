json.id user_location.id
json.name user_location.name
json.position user_location.position
json.bounds user_location.bounds
json.alerts_enabled user_location.alerts_enabled
json.created_at user_location.created_at
json.updated_at user_location.updated_at

if user_location.location_id.present?
  json.location_type "system"
  json.location do
    json.id user_location.location.id
    json.name user_location.location.name
    json.iso user_location.location.iso
    json.location_type user_location.location.location_type
    json.bounds user_location.location.bounds
  end
else
  json.location_type "custom"
  json.custom_geometry RGeo::GeoJSON.encode(user_location.custom_geometry) if user_location.custom_geometry
end

