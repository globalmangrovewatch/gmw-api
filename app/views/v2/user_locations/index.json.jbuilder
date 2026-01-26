json.data do
  json.array! @user_locations do |user_location|
    json.partial! "v2/user_locations/user_location", user_location: user_location
  end
end

json.meta do
  json.max_locations UserLocation::MAX_LOCATIONS_PER_USER
  json.current_count @user_locations.size
end

