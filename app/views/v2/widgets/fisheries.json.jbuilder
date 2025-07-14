json.data do
  json.array! @data do |fishery|
    json.indicator fishery.indicator
    json.value fishery.value
    json.year @year
    json.category fishery.category
    json.fishery_type fishery.fishery_type
  end
end

json.metadata do
  json.location_id @location_id
  json.unit "fishing days"
end
