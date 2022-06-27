json.array! @landscapes do |landscape|
  json.id landscape.id
  json.landscape_name landscape.landscape_name
  json.organizations landscape.organizations do |organization|
    json.id organization.id
    json.organization_name organization.organization_name
  end
end
