json.data do
  json.array! @data do |data|
    json.indicator data.indicator
    json.category data.category
    json.value data.value
  end
end

json.metadata do
  json.ecoregion_total Ecoregion.where(category: %w[vu en ce]).sum(:value)
  json.reports do
    json.array! @reports do |report|
      json.name report.name
      json.url report.url
    end
  end
end
