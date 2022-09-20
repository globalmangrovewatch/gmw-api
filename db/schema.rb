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

ActiveRecord::Schema[7.0].define(version: 2022_09_16_135810) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "aboveground_biomasses_indicators", ["total", "avg", "0-50", "50-100", "100-150", "150-250", "250-1500"]
  create_enum "degradation_indicators", ["degraded_area", "lost_area", "main_loss_driver"]
  create_enum "degradation_units", ["ha", "%"]
  create_enum "habitat_extent_indicators", ["habitat_extent_area", "linear_coverage"]
  create_enum "mangrove_types", ["estuary", "delta", "lagoon", "fringe"]
  create_enum "new_degradation_indicators", ["degraded_area", "lost_area", "mangrove_area"]
  create_enum "red_list_cat", ["ex", "ew", "re", "cr", "en", "vu", "lr", "nt", "lc", "dd"]
  create_enum "restoration_indicators", ["restorable_area", "mangrove_area", "restoration_potential_score"]
  create_enum "restoration_units", ["ha", "%"]
  create_enum "tree_heights_indicators", ["0-5", "5-10", "10-15", "15-20", "20-65", "avg"]

  create_table "aboveground_biomasses", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.enum "indicator", default: "total", null: false, enum_type: "aboveground_biomasses_indicators"
    t.integer "year"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_aboveground_biomasses_on_location_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "blue_carbon_investments", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.string "category"
    t.float "area"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_blue_carbon_investments_on_location_id"
  end

  create_table "blue_carbons", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.string "indicator"
    t.integer "year"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_blue_carbons_on_location_id"
  end

  create_table "degradation_treemaps", force: :cascade do |t|
    t.float "value"
    t.enum "unit", default: "ha", null: false, enum_type: "degradation_units"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year", default: 2016
    t.text "main_loss_driver"
    t.string "indicator", null: false
    t.index ["location_id"], name: "index_degradation_treemaps_on_location_id"
  end

  create_table "ecosystem_services", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.string "indicator"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_ecosystem_services_on_location_id"
  end

  create_table "habitat_extents", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.enum "indicator", default: "habitat_extent_area", null: false, enum_type: "habitat_extent_indicators"
    t.integer "year"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_habitat_extents_on_location_id"
  end

  create_table "international_statuses", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.string "indicator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["location_id"], name: "index_international_statuses_on_location_id"
  end

  create_table "intervention_answers", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.string "question_id"
    t.json "answer_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_intervention_answers_on_site_id"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "landscapes", force: :cascade do |t|
    t.string "landscape_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landscape_name"], name: "index_landscapes_on_landscape_name", unique: true
  end

  create_table "landscapes_organizations", force: :cascade do |t|
    t.bigint "landscape_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landscape_id"], name: "index_landscapes_organizations_on_landscape_id"
    t.index ["organization_id"], name: "index_landscapes_organizations_on_organization_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "location_type"
    t.string "iso"
    t.json "bounds"
    t.json "geometry"
    t.float "area_m2"
    t.float "perimeter_m"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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

  create_table "mitigation_potentials", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.string "indicator"
    t.string "category"
    t.integer "year"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_mitigation_potentials_on_location_id"
  end

  create_table "monitoring_answers", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.date "monitoring_date"
    t.string "question_id"
    t.json "answer_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.string "form_type"
    t.index ["site_id"], name: "index_monitoring_answers_on_site_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "organization_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_name"], name: "index_organizations_on_organization_name", unique: true
  end

  create_table "organizations_users", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id"], name: "index_organizations_users_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_organizations_users_on_organization_id"
    t.index ["user_id"], name: "index_organizations_users_on_user_id"
  end

  create_table "registration_answers", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.string "question_id"
    t.json "answer_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_registration_answers_on_site_id"
  end

  create_table "restoration_potentials", force: :cascade do |t|
    t.enum "indicator", default: "restorable_area", null: false, enum_type: "restoration_indicators"
    t.float "value"
    t.enum "unit", default: "ha", null: false, enum_type: "restoration_units"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year", default: 2016
    t.index ["location_id"], name: "index_restoration_potentials_on_location_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "site_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "landscape_id", null: false
    t.json "section_data_visibility"
    t.geometry "area", limit: {:srid=>4326, :type=>"geometry"}
    t.index ["area"], name: "index_sites_on_area", using: :gist
    t.index ["landscape_id"], name: "index_sites_on_landscape_id"
    t.index ["site_name"], name: "index_sites_on_site_name", unique: true
  end

  create_table "species", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scientific_name"
    t.string "common_name"
    t.string "iucn_url"
    t.enum "red_list_cat", default: "ex", null: false, enum_type: "red_list_cat"
  end

  create_table "species_locations", force: :cascade do |t|
    t.bigint "specie_id"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_species_locations_on_location_id"
    t.index ["specie_id"], name: "index_species_locations_on_specie_id"
  end

  create_table "tree_heights", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.enum "indicator", default: "avg", null: false, enum_type: "tree_heights_indicators"
    t.integer "year"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_tree_heights_on_location_id"
  end

  create_table "typologies", force: :cascade do |t|
    t.integer "value"
    t.string "unit", default: "ha"
    t.enum "mangrove_types", default: "estuary", null: false, enum_type: "mangrove_types"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_typologies_on_location_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "admin", default: false, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "widget_protected_areas", force: :cascade do |t|
    t.integer "year"
    t.float "total_area"
    t.float "protected_area"
    t.string "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "aboveground_biomasses", "locations"
  add_foreign_key "blue_carbon_investments", "locations"
  add_foreign_key "blue_carbons", "locations"
  add_foreign_key "degradation_treemaps", "locations"
  add_foreign_key "ecosystem_services", "locations"
  add_foreign_key "habitat_extents", "locations"
  add_foreign_key "international_statuses", "locations"
  add_foreign_key "intervention_answers", "sites"
  add_foreign_key "landscapes_organizations", "landscapes"
  add_foreign_key "landscapes_organizations", "organizations"
  add_foreign_key "mangrove_data", "locations"
  add_foreign_key "mitigation_potentials", "locations"
  add_foreign_key "monitoring_answers", "sites"
  add_foreign_key "organizations_users", "organizations"
  add_foreign_key "organizations_users", "users"
  add_foreign_key "registration_answers", "sites"
  add_foreign_key "restoration_potentials", "locations"
  add_foreign_key "sites", "landscapes"
  add_foreign_key "tree_heights", "locations"
  add_foreign_key "typologies", "locations"
  add_foreign_key "widget_protected_areas", "locations", primary_key: "location_id", on_delete: :cascade
end
