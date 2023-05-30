json.data do
  json.array! @indicators do |indicator|
    json.indicator indicator
    json.value @data.find { |d| d.indicator == indicator }&.value
  end
end

json.metadata do
  json.location_id @location_id
  json.unit "mt CO₂ e"
  json.note nil
end
