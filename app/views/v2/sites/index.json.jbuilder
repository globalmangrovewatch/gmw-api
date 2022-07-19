json.array! @sites do |site|
  json.id site.id
  json.site_name site.site_name
  json.landscape_id site.landscape.id
  json.landscape_name site.landscape.landscape_name
  json.section_last_updated site.section_last_updated
  json.section_data_visibility site.section_data_visibility
end
