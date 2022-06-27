json.id @landscape.id
json.landscape_name @landscape.landscape_name
json.organizations do
    json.array! @organizations do |organization|
    json.id organization.id
    json.organization_name organization.organization_name
    end
end
json.sites @landscape.sites do |site|
    json.site_id site.id
    json.site_name site.site_name
end