json.data do
  json.array! @organizations do |organization|
    json.partial! "organization", organization: organization
    json.landscapes organization.landscapes do |landscape|
      json.id landscape.id
      json.landscape_name landscape.landscape_name
    end
    json.role organization.role
  end
end

json.meta do
  json.page @page
  json.per_page @per_page
  json.total @total
end
