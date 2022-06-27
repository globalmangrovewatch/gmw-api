json.array! @landscapes do |landscape|
  json.id landscape.id
  json.landscape_name landscape.landscape_name
  json.organizations landscape.organizations do |organization|
    json.id organization.id
    json.organization_name organization.organization_name
  end
  json.sites landscape.sites do |site|
    json.site_id site.id unless
    json.site_name site.site_name
  end
end
