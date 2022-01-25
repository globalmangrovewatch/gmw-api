json.meta do
  json.year do
    json.array! @year do |year|
      json.year date.year
    end 
  end
end

json.data do
  json.array! @protected_areas do |protected_areas|
    json.id protected_areas.id
    json.year protected_areas.year
    json.total_area protected_areas.total_area
    json.protected_area protected_areas.protected_area
  end
end