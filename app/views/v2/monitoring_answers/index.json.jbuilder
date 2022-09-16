json.array! @monitoring_forms do |form|
  json.id form.uuid
  json.form_type form.form_type
  json.monitoring_date form.monitoring_date
end
