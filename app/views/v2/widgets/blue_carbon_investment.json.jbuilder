total = @data.pluck(:area).sum

json.data do
  json.array! @data do |datum|
    json.category datum.category
    json.value datum.area
    json.percentage datum.area / total * 100
    json.text datum.description
  end
end

json.metadata do
  json.total total
  json.location_id @data.pluck(:location_id).first
  json.unit 'ha'
  json.note nil
end