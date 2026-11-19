json.array! @organizations do |organization|
  json.id organization.id
  json.organization_name organization.organization_name
  json.regions organization.regions
  json.gma_membership organization.gma_membership
  json.gma_chapter_name organization.gma_chapter_name
  json.gma_status organization.gma_status
  json.created_at organization.created_at
end
