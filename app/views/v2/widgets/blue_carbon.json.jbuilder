json.data do
  json.array! @data do |datum|
    json.year datum.year
    json.indicator datum.indicator
    json.value datum.value
  end
end

json.metadata do
  json.location_id @location_id
  json.units do
    json.value 'CO2e/ha'
  end
  json.year @data.pluck(:year).uniq.sort.reverse
  json.note nil
end