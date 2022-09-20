class AddFormTypeToMonitoringAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :monitoring_answers, :uuid, :string
    add_column :monitoring_answers, :form_type, :string
  end
end
