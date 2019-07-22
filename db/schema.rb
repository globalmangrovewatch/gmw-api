# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_18_160406) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["location_id"], name: "index_mangrove_data_on_location_id"
  end

  add_foreign_key "mangrove_data", "locations"
end
