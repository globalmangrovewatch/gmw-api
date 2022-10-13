json.site_id @site.id

json.registration_intervention_answers do
  @registration_intervention_answers.each{ |answer| json.set! answer.question_id, answer.answer_value }
end

json.monitoring_answers @monitoring_answers
