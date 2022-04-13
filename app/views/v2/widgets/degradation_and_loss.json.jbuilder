json.data do
  json.array! @data do |datum|
    json.indicator datum.indicator
    json.value datum.value
  end
end

json.metadata do
  json.location_id @data.pluck(:location_id).first
  json.year @data.pluck(:year).first
  json.units do
    json.degraded_area @data.find_by(indicator: 'degraded_area').unit
    json.lost_area @data.find_by(indicator: 'lost_area').unit
    json.mangrove_area @data.find_by(indicator: 'mangrove_area').unit
  end
  json.main_loss_driver @data.first.main_loss_driver
  json.note nil
end