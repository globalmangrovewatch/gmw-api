json.array! @organizations do |organization|
  json.id organization.id
  json.organization_name organization.organization_name
  json.landscapes organization.landscapes do |landscape|
    json.id landscape.id
    json.landscape_name landscape.landscape_name
  end
end
