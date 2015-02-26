# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150226085730) do

  create_table "articles", force: true do |t|
    t.string   "number"
    t.integer  "criminal_code_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["criminal_code_id"], name: "index_articles_on_criminal_code_id"
  add_index "articles", ["number"], name: "index_articles_on_number"

  create_table "charges", force: true do |t|
    t.integer  "incident_id"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "charges", ["article_id"], name: "index_charges_on_article_id"
  add_index "charges", ["incident_id"], name: "index_charges_on_incident_id"

  create_table "criminal_codes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "incidents", force: true do |t|
    t.integer  "prisoner_id"
    t.date     "date_of_arrest"
    t.text     "description_of_arrest"
    t.integer  "prison_id"
    t.integer  "type_id"
    t.integer  "subtype_id"
    t.date     "date_of_release"
    t.text     "description_of_release"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incidents", ["date_of_arrest"], name: "index_incidents_on_date_of_arrest"
  add_index "incidents", ["date_of_release"], name: "index_incidents_on_date_of_release"
  add_index "incidents", ["prison_id"], name: "index_incidents_on_prison_id"
  add_index "incidents", ["prisoner_id"], name: "index_incidents_on_prisoner_id"
  add_index "incidents", ["subtype_id"], name: "index_incidents_on_subtype_id"
  add_index "incidents", ["type_id"], name: "index_incidents_on_type_id"

  create_table "incidents_tags", id: false, force: true do |t|
    t.integer "incident_id"
    t.integer "tag_id"
  end

  add_index "incidents_tags", ["incident_id"], name: "index_incidents_tags_on_incident_id"
  add_index "incidents_tags", ["tag_id"], name: "index_incidents_tags_on_tag_id"

  create_table "prisoners", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "portrait_file_name"
    t.string   "portrait_content_type"
    t.integer  "portrait_file_size"
    t.datetime "portrait_updated_at"
    t.boolean  "currently_imprisoned"
  end

  add_index "prisoners", ["name"], name: "index_prisoners_on_name"

  create_table "prisons", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "prisons", ["name"], name: "index_prisons_on_name"

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], name: "index_roles_on_name"

  create_table "tags", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["role_id"], name: "index_users_on_role_id"

end
