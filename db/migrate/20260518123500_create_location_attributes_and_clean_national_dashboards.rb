class CreateLocationAttributesAndCleanNationalDashboards < ActiveRecord::Migration[7.0]
  def up
    create_table :location_attributes do |t|
      t.references :location, null: false, foreign_key: true
      t.string :legal_status
      t.boolean :mangrove_breakthrough_committed, default: false, null: false

      t.timestamps
    end

    add_index :location_attributes, :location_id, unique: true

    migrate_existing_data

    remove_column :national_dashboards, :legal_status, :string if column_exists?(:national_dashboards, :legal_status)
    remove_column :national_dashboards, :mangrove_breakthrough_committed, :boolean if column_exists?(:national_dashboards, :mangrove_breakthrough_committed)
  end

  def down
    drop_table :location_attributes

    add_column :national_dashboards, :legal_status, :string
    add_column :national_dashboards, :mangrove_breakthrough_committed, :boolean
  end

  private

  def migrate_existing_data
    has_legal_status = column_exists?(:national_dashboards, :legal_status)
    has_breakthrough = column_exists?(:national_dashboards, :mangrove_breakthrough_committed)

    return unless has_legal_status || has_breakthrough

    columns = [:location_id]
    columns << :legal_status if has_legal_status
    columns << :mangrove_breakthrough_committed if has_breakthrough

    rows = execute(<<~SQL)
      SELECT DISTINCT ON (location_id) #{columns.join(", ")}
      FROM national_dashboards
      WHERE #{columns.drop(1).map { |c| "#{c} IS NOT NULL" }.join(" OR ")}
      ORDER BY location_id, id ASC
    SQL

    now = Time.current

    rows.each do |row|
      execute(<<~SQL)
        INSERT INTO location_attributes (location_id, legal_status, mangrove_breakthrough_committed, created_at, updated_at)
        VALUES (
          #{row["location_id"]},
          #{row["legal_status"] ? "'#{row["legal_status"]}'" : "NULL"},
          #{row["mangrove_breakthrough_committed"] || false},
          '#{now}',
          '#{now}'
        )
        ON CONFLICT (location_id) DO NOTHING
      SQL
    end
  end
end
