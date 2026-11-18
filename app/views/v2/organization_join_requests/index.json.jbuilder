json.array! @join_requests do |join_request|
  json.id join_request.id
  json.status join_request.status
  json.message join_request.message
  json.requester_name join_request.requester_name
  json.created_at join_request.created_at
end
