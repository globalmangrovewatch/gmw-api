json.data do
  json.array! @data do |datum|
    json.year datum.year
    json.net_change datum.value
    json.gain nil
    json.loss nil
  end
end

json.metadata do
  json.location_id @location_id
  json.units do
    json.net_change 'km2'
  end
  json.year [1996,
    2007,
    2008,
    2009,
    2010,
    2015,
    2016,
    2017,
    2018,
    2019,
    2020]
  json.note nil
  json.total_area @total_area
  json.total_lenght @total_lenght
end