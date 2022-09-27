json.array! @answers do |answer|
  json.site_id answer[:site_id]
  json.question_id answer[:question_id]
  json.answer_value answer[:answer_value]
end
