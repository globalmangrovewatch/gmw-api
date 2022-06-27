json.array! @landscapes do |landscape|
  json.id landscape.id
  json.landscape_name landscape.landscape_name
  json.organizations landscape.organizations do |organization|
    json.id organization.id
    json.organization_name organization.organization_name
  end
  json.site_id landscape.site.id unless landscape.site.nil?
  json.site_name landscape.site.site_name unless landscape.site.nil?
end
