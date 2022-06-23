class ChangeEcosytemServicesValueType < ActiveRecord::Migration[7.0]
  def change
    remove_column :international_statuses, :value
    add_column :international_statuses, :value, :string, null: false
  end
end
