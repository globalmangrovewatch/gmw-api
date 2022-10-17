class DropInterventionAnswersTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :intervention_answers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
