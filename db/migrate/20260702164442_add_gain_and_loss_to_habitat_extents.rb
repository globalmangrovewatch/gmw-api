class AddGainAndLossToHabitatExtents < ActiveRecord::Migration[7.0]
  def change
    add_column :habitat_extents, :gain, :float
    add_column :habitat_extents, :loss, :float
  end
end
