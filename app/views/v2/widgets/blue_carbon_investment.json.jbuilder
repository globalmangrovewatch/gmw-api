json.data do
  json.array! @data do |datum|
    json.category datum.category
    json.value datum.area * @conversion_factor
    json.percentage datum.area / datum.total_area * 100
    json.description datum.description
    json.label @labels[datum.category]
  end
end

json.metadata do
  json.location_id @location_id
  json.unit @unit
  json.note nil
end