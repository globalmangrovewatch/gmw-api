json.array! @sites do |site|
  json.id site.id
  json.site_name site.site_name
  json.landscape_id site.landscape_id
end
