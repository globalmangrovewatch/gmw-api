json.data do
  json.array! @protected_areas do |protected_areas|
    json.id protected_areas.id
    json.year protected_areas.year
    json.total_area protected_areas.total_area * @conversion_factor
    json.protected_area protected_areas.protected_area * @conversion_factor
  end
end

json.metadata do
  json.location_id @location_id
  json.units do
    json.total_area @unit
    json.protected_area @unit
  end
  json.year @protected_areas.pluck(:year).uniq.sort.reverse
end