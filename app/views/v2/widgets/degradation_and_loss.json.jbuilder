json.data do
  json.array! @data do |datum|
    json.indicator datum.indicator
    json.value datum.indicator == 'lost_area' ? datum.value - @restorable_area.value : datum.value
    json.label datum.indicator == 'lost_area' ? 'Non-Restorable Lost Mangrove Area' : datum.indicator
  end
end

json.metadata do
  json.location_id @location_id
  json.year @year
  json.units do
    json.degraded_area @degraded_area ? @degraded_area.unit : nil
    json.lost_area @lost_area ? @lost_area.unit  : nil
    json.mangrove_area @mangrove_area ? @mangrove_area.unit  : nil
  end
  json.main_loss_driver @lost_driver ? @lost_driver.main_loss_driver : nil
  json.note nil
end