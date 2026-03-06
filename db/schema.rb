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

ActiveRecord::Schema[7.2].define(version: 2026_03_02_124815) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "axes", force: :cascade do |t|
    t.string "name", null: false
    t.string "label_min", null: false
    t.string "label_max", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_axes_on_name", unique: true
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.string "icon"
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
    t.index ["slug"], name: "index_genres_on_slug", unique: true
  end

  create_table "main_styles", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "photo_scores", force: :cascade do |t|
    t.bigint "photo_id", null: false
    t.bigint "axis_id", null: false
    t.integer "score", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["axis_id"], name: "index_photo_scores_on_axis_id"
    t.index ["photo_id", "axis_id"], name: "index_photo_scores_on_photo_id_and_axis_id", unique: true
    t.index ["photo_id"], name: "index_photo_scores_on_photo_id"
  end

  create_table "photos", force: :cascade do |t|
    t.bigint "genre_id", null: false
    t.bigint "main_style_id"
    t.string "image_path"
    t.boolean "is_representative", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_photos_on_genre_id"
    t.index ["main_style_id"], name: "index_photos_on_main_style_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_name", null: false
    t.index ["account_name"], name: "index_users_on_account_name", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "photo_scores", "axes"
  add_foreign_key "photo_scores", "photos"
  add_foreign_key "photos", "genres"
  add_foreign_key "photos", "main_styles"
end
