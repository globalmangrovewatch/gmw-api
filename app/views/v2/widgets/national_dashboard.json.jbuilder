indicators_data = @data.group_by(&:indicator)
indicator_keys = if indicators_data.any?
  indicators_data.keys
elsif @location_attribute
  NationalDashboard.indicators.keys
else
  []
end

json.data do
  json.array! indicator_keys do |indicator|
    data = indicators_data[indicator] || []
    json.indicator indicator
    json.legal_status @location_attribute&.legal_status
    json.mangrove_breakthrough_committed @location_attribute&.mangrove_breakthrough_committed || false
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
  json.legal_status_options LocationAttribute.legal_status_options
  json.other_resources do
    json.array! @location_resources do |location_resource|
      json.name location_resource.name
      json.description location_resource.description
      json.link location_resource.link
    end
  end
  json.note nil
end
