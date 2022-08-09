json.meta do
  json.dates do
    json.array! @dates do |date|
      json.date date.date
    end 
  end
end

json.data do
  json.array! @locations
end
