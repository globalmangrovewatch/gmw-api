json.data do
  json.organization Organization.pluck(:organization_name)
  json.intervention_type RegistrationInterventionAnswer::QUESTIONS["6.2"]
  json.cause_of_decline RegistrationInterventionAnswer::QUESTIONS["4.2"]
  json.ecological_aim RegistrationInterventionAnswer::QUESTIONS["3.1"]
  json.socioeconomic_aim RegistrationInterventionAnswer::QUESTIONS["3.2"]
  json.community_activities RegistrationInterventionAnswer::QUESTIONS["6.4"]
end
