class CreateMonitoringAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :monitoring_answers do |t|
      t.belongs_to :site, null: false, foreign_key: true
      t.date :monitoring_date
      t.string :question_id
      t.json :answer_value

      t.timestamps
    end
  end
end
