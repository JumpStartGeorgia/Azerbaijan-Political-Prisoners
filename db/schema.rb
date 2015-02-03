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

ActiveRecord::Schema.define(version: 20150203073452) do

  create_table "articles", force: true do |t|
    t.string   "number"
    t.integer  "criminal_code_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["criminal_code_id"], name: "index_articles_on_criminal_code_id"

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

  add_index "incidents", ["prison_id"], name: "index_incidents_on_prison_id"
  add_index "incidents", ["prisoner_id"], name: "index_incidents_on_prisoner_id"
  add_index "incidents", ["subtype_id"], name: "index_incidents_on_subtype_id"
  add_index "incidents", ["type_id"], name: "index_incidents_on_type_id"

  create_table "prisoners", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "portrait_file_name"
    t.string   "portrait_content_type"
    t.integer  "portrait_file_size"
    t.datetime "portrait_updated_at"
  end

  create_table "prisons", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subtypes", force: true do |t|
    t.string   "name"
    t.integer  "type_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subtypes", ["type_id"], name: "index_subtypes_on_type_id"

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
