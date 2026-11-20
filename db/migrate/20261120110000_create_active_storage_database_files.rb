class CreateActiveStorageDatabaseFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :active_storage_database_files do |t|
      t.string :key, null: false
      t.binary :data, null: false
      t.timestamps
    end

    add_index :active_storage_database_files, :key, unique: true
  end
end
