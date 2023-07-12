json.data do
  json.array! FloodProtection.periods.keys.each do |period|
    json.indicator @indicator
    json.period period
    json.value @data.detect { |d| d.period == period }&.value.to_f
  end
end

json.metadata do
  json.location_id @location_id
  json.unit FloodProtection::UNITS_BY_INDICATOR[@indicator.to_sym]
  json.periods FloodProtection.periods.keys
  json.limits do
    FloodProtection.periods.keys.each do |period|
      json.set! period do
        json.min @limits[period]&.first&.min || 0
        json.max @limits[period]&.first&.max || 0
      end
    end
  end
end
