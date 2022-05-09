restoration_potential_score = @data.find_by(indicator: 'restoration_potential_score')
restorable_area = @data.find_by(indicator: 'restorable_area')
mangrove_area = @data.find_by(indicator: 'mangrove_area')
restorable_area_perc = restorable_area && mangrove_area ? (restorable_area.value / mangrove_area.value) * 100 : nil

json.data do
  json.restoration_potential_score restoration_potential_score ? restoration_potential_score.value : nil
  json.restorable_area restorable_area ? restorable_area.value : nil
  json.restorable_area_perc restorable_area_perc
  json.mangrove_area_extent mangrove_area ? mangrove_area.value : nil
end

json.metadata do
  json.location_id @location_id
  json.year @year
  json.units do
    json.restoration_potential_score restoration_potential_score ? restoration_potential_score.unit : nil
    json.restorable_area restorable_area ? restorable_area.unit : nil
    json.mangrove_area mangrove_area ? mangrove_area.unit : nil
  end
  json.note nil
end