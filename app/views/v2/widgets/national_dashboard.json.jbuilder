json.data do
  json.array! @data.group_by(&:indicator) do |indicator, data|
    json.indicator indicator
    json.sources do
      json.array! data.group_by(&:source) do |source, data_source|
        json.source source
        json.unit data_source.first&.unit
        json.years data_source.map(&:year).uniq.sort
        json.data_source do
          json.array! data_source do |record|
            json.year record.year
            json.value record.value
            json.layer_info record.layer_info
            json.layer_link record.layer_link
            json.download_link record.download_link
            json.source_layer record.source_layer
          end
        end
      end
    end
  end
end

json.metadata do
  json.location_id @location_id
  json.other_resources do
    json.array! @location_resources do |location_resource|
      json.name location_resource.name
      json.description location_resource.description
      json.link location_resource.link
    end
  end
  json.note nil
end
