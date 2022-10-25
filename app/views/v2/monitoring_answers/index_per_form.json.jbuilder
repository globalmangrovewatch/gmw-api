json.id @uuid
json.form_type @form_type
json.answers @answers do |answer|
  if not @restricted_sections.include?(answer.question_id.split(".")[0])
    json.question_id answer.question_id
    json.monitoring_date answer.monitoring_date
    json.answer_value answer.answer_value
  end
end
