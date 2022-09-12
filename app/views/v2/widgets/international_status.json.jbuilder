json.data @data
#  do
#   json.array! @data do |datum|
#     json.location_id datum.header
#     datum.orthogonal_headers.zip(datum.data).each do |key, value|
#       json.set! key, value
#     end
#   end
# end

json.metadata do
  json.location_id @location_id
  json.note nil
end