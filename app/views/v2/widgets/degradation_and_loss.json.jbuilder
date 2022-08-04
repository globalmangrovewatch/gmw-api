json.data do
  json.array! @data do |datum|
    json.indicator datum.indicator
    json.value datum.value
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