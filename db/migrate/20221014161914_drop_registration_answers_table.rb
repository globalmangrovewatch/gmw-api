class DropRegistrationAnswersTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :registration_answers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
