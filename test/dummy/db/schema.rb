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

ActiveRecord::Schema[7.2].define(version: 2025_02_19_063638) do
  create_table "descripto_descriptions", force: :cascade do |t|
    t.string "name"
    t.string "name_key"
    t.string "description_type"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "descripto_descriptives", force: :cascade do |t|
    t.integer "description_id", null: false
    t.bigint "describable_id"
    t.string "describable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["description_id"], name: "index_descripto_descriptives_on_description_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "descripto_descriptives", "descripto_descriptions", column: "description_id"
end
