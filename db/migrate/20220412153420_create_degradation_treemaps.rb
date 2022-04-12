class CreateDegradationTreemaps < ActiveRecord::Migration[7.0]
  def change
    create_table :degradation_treemaps do |t|
      t.float :value

      t.timestamps
    end
  end
end
