json.array! @answers do |answer|
  if !@restricted_sections.include?(answer.question_id.split(".")[0])
    json.question_id answer.question_id
    json.answer_value answer.answer_value
  end
end
