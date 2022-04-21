location = @data.pluck(:location_id)
year = @data.pluck(:year)
degraded_area = @data.find_by(indicator: 'degraded_area')
lost_area = @data.find_by(indicator: 'lost_area')
mangrove_area = @data.find_by(indicator: 'mangrove_area')
lost_driver = @data.first

json.data do
  json.array! @data do |datum|
    json.indicator datum.indicator
    json.value datum.value
  end
end

json.metadata do
  json.location_id location ? location.first : nil
  json.year year ? year.first : nil
  json.units do
    json.degraded_area degraded_area ? degraded_area.unit : nil
    json.lost_area lost_area ? lost_area.unit  : nil
    json.mangrove_areamangrove_area ? mangrove_area.unit  : nil
  end
  json.main_loss_driver lost_driver ? lost_driver.main_loss_driver : nil
  json.note nil
end