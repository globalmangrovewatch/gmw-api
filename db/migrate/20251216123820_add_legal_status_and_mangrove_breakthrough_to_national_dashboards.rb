class AddLegalStatusAndMangroveBreakthroughToNationalDashboards < ActiveRecord::Migration[7.0]
  def change
    add_column :national_dashboards, :legal_status, :string
    add_column :national_dashboards, :mangrove_breakthrough_committed, :boolean
  end
end
