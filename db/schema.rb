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

ActiveRecord::Schema.define(version: 2021_04_23_141043) do

  create_table "hints", force: :cascade do |t|
    t.string "title", null: false
    t.string "url", null: false
    t.string "fingerprint", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source", null: false
    t.index ["fingerprint", "source"], name: "index_hints_on_fingerprint_and_source", unique: true
    t.index ["fingerprint"], name: "index_hints_on_fingerprint"
    t.index ["source"], name: "index_hints_on_source"
  end

end
