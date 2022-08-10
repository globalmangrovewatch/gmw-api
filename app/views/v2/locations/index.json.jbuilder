json.meta do
  json.dates do
    json.array! @dates do |date|
      json.date date.year.to_s + '-01-01'
    end 
  end
end

json.data do
  json.array! @locations
end
