json.data do
  json.array! @data do |datum|
    json.indicator datum.indicator
    json.value (datum.indicator == "lost_area") ? datum.value - @restorable_area.value : datum.value
    json.label @labels[datum.indicator]
  end
end

json.metadata do
  json.location_id @location_id
  json.year @year
  json.units do
    json.degraded_area @degraded_area&.unit
    json.lost_area @lost_area&.unit
    json.mangrove_area @mangrove_area&.unit
  end
  json.main_loss_driver @lost_driver&.main_loss_driver
  json.note nil
end
