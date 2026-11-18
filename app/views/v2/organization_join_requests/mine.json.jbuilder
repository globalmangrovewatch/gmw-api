json.array! @join_requests do |join_request|
  json.id join_request.id
  json.organization_id join_request.organization_id
  json.organization_name join_request.organization.organization_name
  json.status join_request.status
  json.message join_request.message
  json.created_at join_request.created_at
  json.reviewed_at join_request.reviewed_at
end
