json.array! @countries do |country|
  json.location_id country.location_id
  json.iso country.iso
  json.name country.name
  json.region country.region
end
