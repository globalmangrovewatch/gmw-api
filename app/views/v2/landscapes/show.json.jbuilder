json.id @landscape.id
json.landscape_name @landscape.landscape_name
json.organizations do
    json.array! @organizations do |organization|
    json.id organization.id
    json.organization_name organization.organization_name
    end
end
json.site_id @landscape.site.id unless @landscape.site.nil?
json.site_name @landscape.site.site_name unless @landscape.site.nil?