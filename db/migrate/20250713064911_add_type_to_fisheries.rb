class AddTypeToFisheries < ActiveRecord::Migration[7.0]
  def change
    add_column :fisheries, :fishery_type, :string
  end
end
