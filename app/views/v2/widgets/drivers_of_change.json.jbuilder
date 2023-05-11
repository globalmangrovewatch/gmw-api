json.data do
  json.array! @data do |data|
    json.variable data.variable
    json.primary_driver data.primary_driver
    json.value data.value
  end
end

json.metadata do
  json.location_id @location_id
  json.units do
    json.value "%"
  end
end
