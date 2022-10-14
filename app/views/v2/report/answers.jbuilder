json.array! @answers do |answer|
  json.site_id answer["site_id"]
  json.registration_intervention_answers do
    answer["registration_intervention_answers"].each{ |answer| json.set! answer.question_id, answer.answer_value }
  end
  json.monitoring_answers answer["monitoring_answers"]
end