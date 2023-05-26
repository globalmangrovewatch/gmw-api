class ChangeRegistrationInterventionAnswerValueToJsonB < ActiveRecord::Migration[7.0]
  def up
    change_column :registration_intervention_answers, :answer_value, :jsonb, using: "answer_value::jsonb"
  end

  def down
    change_column :registration_intervention_answers, :answer_value, :json, using: "answer_value::json"
  end
end
