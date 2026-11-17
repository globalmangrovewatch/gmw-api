json.array! @organizations do |organization|
  json.partial! "organization", organization: organization
end
