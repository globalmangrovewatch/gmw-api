json.data do
  json.array! @locations do |location|
    json.location_id location.id
    json.total location.species.distinct.count
    json.threatened location.species.where(red_list_cat: ['cr', 'en', 'vu']).distinct.count
    json.categories location.species.group(:red_list_cat).count
  end
end

json.metadata do
  json.unit nil
  json.note 'nº species'
end