json.data do
  json.array! @data do |data|
    json.id data.id
    json.site_name data.site_name
    json.landscape_id data.landscape.id
    json.landscape_name data.landscape.landscape_name
    json.site_area data.site_area
    json.site_centroid data.site_centroid
  end
end
