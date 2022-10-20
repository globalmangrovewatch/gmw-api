json.array! @answers do |answer|
  json.site_id answer["site_id"]
  if answer["registration_intervention_answers"].length == 0
    json.registration_intervention_answers []
  else
    json.registration_intervention_answers do
      answer["registration_intervention_answers"].each{ |answer| json.set! answer.question_id, answer.answer_value }
    end
  end
  json.monitoring_answers answer["monitoring_answers"]
end