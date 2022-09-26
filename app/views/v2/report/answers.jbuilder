json.registration_answers @registration_answers do |answer|
  json.site_id answer[:site_id]
  json.site_name answer.site.site_name
  json.landscape_name answer.site.landscape.landscape_name
  json.organizations answer.site.landscape.organizations do |organization|
    json.organization_name organization.organization_name
  end
  json.question_id answer[:question_id]
  json.answer_value answer[:answer_value]
end
json.intervention_answers @intervention_answers do |answer|
  json.site_id answer[:site_id]
  json.site_name answer.site.site_name
  json.landscape_name answer.site.landscape.landscape_name
  json.organizations answer.site.landscape.organizations do |organization|
    json.organization_name organization.organization_name
  end
  json.question_id answer[:question_id]
  json.answer_value answer[:answer_value]
end
json.monitoring_answers @monitoring_answers do |answer|
  json.site_id answer[:site_id]
  json.site_name answer.site.site_name
  json.landscape_name answer.site.landscape.landscape_name
  json.organizations answer.site.landscape.organizations do |organization|
    json.organization_name organization.organization_name
  end
  json.monitoring_date answer[:monitoring_date]
  json.uuid answer[:uuid]
  json.form_type answer[:form_type]
  json.question_id answer[:question_id]
  json.answer_value answer[:answer_value]
end