json.id @landscape.id
json.landscape_name @landscape.landscape_name
json.organizations do
    json.array! @organizations do |organization|
    json.id organization.id
    json.organization_name organization.organization_name
    end
end
