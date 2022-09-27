json.data do
  json.array! @data do |datum|
    json.year datum.year
    json.indicator 'net_change'
    json.value datum.value
    json.cum_sum datum.cum_sum
  end
end

json.metadata do
  json.location_id @location_id
  json.units do
    json.net_change 'km2'
  end
  json.year @data.pluck(:year).uniq.sort.reverse
  json.note nil
  json.total_area @total_area
  json.total_lenght @total_lenght
end