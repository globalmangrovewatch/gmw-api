json.array! @sites do |site|
  json.id site.id
  json.site_name site.site_name

  if site.site_centroid.present?
    json.site_centroid JSON.parse(site.site_centroid)
  end

  json.landscape_id site.landscape.id
  json.landscape_name site.landscape.landscape_name

  json.organizations site.landscape.organizations do |organization|
    json.id organization.id
    json.organization_name organization.organization_name
  end
end
