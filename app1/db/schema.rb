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

ActiveRecord::Schema.define(version: 20170125212639) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "businesses", force: :cascade do |t|
    t.string   "name"
    t.string   "website"
    t.string   "address"
    t.string   "email"
    t.string   "phone"
    t.string   "logo_url"
    t.integer  "status_id"
    t.text     "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status_id"], name: "index_businesses_on_status_id", using: :btree
  end

  create_table "consumables", force: :cascade do |t|
    t.string   "udi"
    t.date     "expiration_date"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "devices", force: :cascade do |t|
    t.integer  "business_id"
    t.integer  "serial_number"
    t.string   "software_version"
    t.string   "mac_address"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "license_key"
    t.date     "license_expiration_date"
    t.integer  "license_remaining_uses"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["business_id"], name: "index_devices_on_business_id", using: :btree
  end

  create_table "patients", force: :cascade do |t|
    t.string   "pid"
    t.date     "date_of_birth"
    t.string   "sex"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "business_id"
    t.string   "email_address"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "status_id"
    t.index ["business_id"], name: "index_patients_on_business_id", using: :btree
    t.index ["status_id"], name: "index_patients_on_status_id", using: :btree
  end

  create_table "results", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "patient_id"
    t.integer  "business_id"
    t.integer  "device_id"
    t.integer  "consumable_id"
    t.float    "value"
    t.datetime "result_datetime"
    t.string   "notes"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["business_id"], name: "index_results_on_business_id", using: :btree
    t.index ["consumable_id"], name: "index_results_on_consumable_id", using: :btree
    t.index ["device_id"], name: "index_results_on_device_id", using: :btree
    t.index ["patient_id"], name: "index_results_on_patient_id", using: :btree
    t.index ["user_id"], name: "index_results_on_user_id", using: :btree
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "status"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "business_id"
    t.string   "password"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "super_admin_role"
    t.boolean  "super_user_role"
    t.boolean  "clinic_admin_role"
    t.boolean  "clinic_user_role"
    t.boolean  "patient_role"
    t.boolean  "device_role"
    t.index ["business_id"], name: "index_users_on_business_id", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "businesses", "statuses"
  add_foreign_key "devices", "businesses"
  add_foreign_key "patients", "businesses"
  add_foreign_key "patients", "statuses"
  add_foreign_key "results", "businesses"
  add_foreign_key "results", "consumables"
  add_foreign_key "results", "devices"
  add_foreign_key "results", "patients"
  add_foreign_key "results", "users"
  add_foreign_key "users", "businesses"
end
