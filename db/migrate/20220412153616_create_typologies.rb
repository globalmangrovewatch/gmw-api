class CreateTypologies < ActiveRecord::Migration[7.0]
  def change
    create_table :typologies do |t|
      t.integer :value

      t.timestamps
    end
  end
end
