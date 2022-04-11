# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_04_11_161056) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "red_list_cat", ["ex", "ew", "re", "cr", "en", "vu", "lr", "nt", "lc", "dd"]

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "location_type"
    t.string "iso"
    t.json "bounds"
    t.json "geometry"
    t.float "area_m2"
    t.float "perimeter_m"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "coast_length_m"
    t.string "location_id"
    t.index ["location_id"], name: "index_locations_on_location_id", unique: true
  end

  create_table "mangrove_data", force: :cascade do |t|
    t.date "date"
    t.float "gain_m2"
    t.float "loss_m2"
    t.float "length_m"
    t.float "area_m2"
    t.float "hmax_m"
    t.float "agb_mgha_1"
    t.float "hba_m"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "con_hotspot_summary_km2"
    t.float "net_change_m2"
    t.text "agb_hist_mgha_1"
    t.text "hba_hist_m"
    t.text "hmax_hist_m"
    t.json "total_carbon"
    t.float "agb_tco2e"
    t.float "bgb_tco2e"
    t.float "soc_tco2e"
    t.float "toc_tco2e"
    t.json "toc_hist_tco2eha"
    t.index ["location_id"], name: "index_mangrove_data_on_location_id"
  end

  create_table "species", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "scientific_name"
    t.string "common_name"
    t.string "iucn_url"
    t.enum "red_list_cat", default: "ex", null: false, enum_type: "red_list_cat"
  end

  create_table "species_locations", force: :cascade do |t|
    t.bigint "specie_id"
    t.bigint "location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["location_id"], name: "index_species_locations_on_location_id"
    t.index ["specie_id"], name: "index_species_locations_on_specie_id"
  end

  create_table "widget_protected_areas", force: :cascade do |t|
    t.integer "year"
    t.float "total_area"
    t.float "protected_area"
    t.string "location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "mangrove_data", "locations"
  add_foreign_key "widget_protected_areas", "locations", primary_key: "location_id", on_delete: :cascade
end
