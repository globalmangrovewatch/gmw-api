json.id @uuid
json.form_type @form_type
json.answers @answers do |answer|
  json.question_id answer.question_id
  json.monitoring_date answer.monitoring_date
  json.answer_value answer.answer_value
end
