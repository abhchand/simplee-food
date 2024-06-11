# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_06_07_121525) do

  create_table "configs", id: false, force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.index ["key"], name: "index_configs_on_key", unique: true
  end

  create_table "recipes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.binary "image"
    t.string "serving_size"
    t.json "ingredients"
    t.json "steps"
    t.string "source_url"
    t.text "notes"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "password", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

end
