json.array! @own_organizations do |organization|
  json.partial! "organization", organization: organization
  json.landscapes organization.landscapes do |landscape|
    json.id landscape.id
    json.landscape_name landscape.landscape_name
  end
  json.role organization.role
end
json.array! @other_organizations do |organization|
  json.partial! "organization", organization: organization
  json.landscapes organization.landscapes do |landscape|
    json.id landscape.id
    json.landscape_name landscape.landscape_name
  end
  json.role organization.role
end
