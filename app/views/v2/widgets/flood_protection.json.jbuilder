json.data do
  json.array! @data do |data|
    json.indicator data.indicator
    json.period data.period
    json.value data.value
    json.unit data.unit
  end
end

json.metadata do
  json.location_id @location_id
end
