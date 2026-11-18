json.partial! "organization", organization: @organization
unless controller.controller_path.start_with?("v3/")
  json.admins @organization.acknowledged_admins do |membership|
    json.name membership.user.name
  end
end
