class AddYearToRestorationPotentials < ActiveRecord::Migration[7.0]
  def change
    add_column :restoration_potentials, :year, :integer, default: 2016
  end
end
