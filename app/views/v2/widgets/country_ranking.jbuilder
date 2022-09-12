json.data @data
# do
#   json.array! @data do |datum|
#     json.year datum.year
#     json.indicator 'net_change'
#     json.value datum.value - datum.value_prior
#   end
# end

json.metadata do
  json.location_id @location_id
  json.units do
    json.value 'km2'
  end
  json.note nil
end