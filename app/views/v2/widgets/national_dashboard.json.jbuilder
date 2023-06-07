json.data do
  json.array! @data do |data|
    json.year data.year
    json.source data.source
    json.indicator data.indicator
    json.value data.value
    json.layer_link data.layer_link
    json.download_link data.download_link
    json.unit data.unit
  end
end

json.metadata do
  json.location_id @location_id
  json.location_resources do
    json.array! @location_resources do |location_resource|
      json.name location_resource.name
      json.description location_resource.description
      json.link location_resource.link
    end
  end
  json.units @data.group_by(&:indicator).map { |k, v| [k, v.first.unit] }.to_h
  json.years @data.map(&:year).uniq.sort
  json.note nil
end
