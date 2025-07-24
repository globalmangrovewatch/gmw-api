json.data do
  json.array! @data do |data|
    json.id data.id
    json.site_name data.site_name
    json.landscape_id data.landscape.id
    json.landscape_name data.landscape.landscape_name
    json.site_area data.site_area
    json.site_centroid data.site_centroid
    json.causes_of_decline data.causes_of_decline
    json.ecological_aims data.ecological_aims
    json.socioeconomic_aims data.socioeconomic_aims
    json.community_activities data.community_activities
    json.intervention_types data.intervention_types
    json.organizations data.organization_names
  end
end

json.metadata do
  json.location_id @location_id
end
