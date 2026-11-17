json.id organization.id
json.organization_name organization.organization_name
json.countries organization.countries do |country|
  json.location_id country.location_id
  json.iso country.iso
  json.name country.name
end
json.regions organization.regions
