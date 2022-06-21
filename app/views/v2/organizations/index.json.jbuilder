json.array! @organizations do |organization|
  json.id organization.id
  json.organization_name organization.organization_name
end
