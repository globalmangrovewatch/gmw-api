json.id organization.id
json.organization_name organization.organization_name
json.countries organization.countries do |country|
  json.location_id country.location_id
  json.iso country.iso
  json.name country.name
end
json.regions organization.regions
gma = gma_fields_for(organization)
if gma.key?(:gma_membership)
  json.gma_membership gma[:gma_membership]
  json.gma_status gma[:gma_status]
  json.gma_chapter_name gma[:gma_chapter_name]
elsif gma.key?(:gma_member)
  json.gma_member gma[:gma_member]
end
