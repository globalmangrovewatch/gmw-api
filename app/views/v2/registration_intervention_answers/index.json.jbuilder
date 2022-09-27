json.array! @answers do |answer|
  json.question_id answer.question_id
  json.answer_value answer.answer_value
end
