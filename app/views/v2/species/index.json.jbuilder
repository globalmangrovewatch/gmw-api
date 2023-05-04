json.data do
  json.array! @species do |specie|
    json.scientific_name specie.scientific_name
    json.common_name specie.common_name
    json.iucn_url specie.iucn_url
    json.red_list_cat specie.red_list_cat
    json.location_ids specie.locations.pluck(:id)
  end
end
