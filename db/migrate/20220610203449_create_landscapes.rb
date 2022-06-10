class CreateLandscapes < ActiveRecord::Migration[7.0]
  def change
    create_table :landscapes do |t|
      t.string :landscape_name

      t.timestamps
    end
  end
end
