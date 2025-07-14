json.data do
  json.array! @data do |fishery_mitigation_potential|
    json.indicator fishery_mitigation_potential.indicator
    json.indicator_type fishery_mitigation_potential.indicator_type
    json.value fishery_mitigation_potential.value
  end
end

json.metadata do
  json.location_id @location_id
  json.unit "fishing days"
end
