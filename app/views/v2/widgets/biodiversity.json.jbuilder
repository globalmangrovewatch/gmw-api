json.data do
    json.total @data.select(:species).distinct(:id).count
    json.threatened @data.select(:species).where('species.red_list_cat': ['cr', 'en', 'vu']).distinct.count
    json.categories @data.select(:species).group(:red_list_cat).distinct.count
end

json.metadata do
  json.unit nil
  json.note 'nº of species'
end