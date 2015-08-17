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

ActiveRecord::Schema.define(version: 20_150_817_102_512) do
  create_table 'article_translations', force: :cascade do |t|
    t.integer 'article_id',  limit: 4,     null: false
    t.string 'locale',      limit: 255,   null: false
    t.datetime 'created_at',                null: false
    t.datetime 'updated_at',                null: false
    t.text 'description', limit: 65_535
  end

  add_index 'article_translations', ['article_id'], name: 'index_article_translations_on_article_id', using: :btree
  add_index 'article_translations', ['locale'], name: 'index_article_translations_on_locale', using: :btree

  create_table 'articles', force: :cascade do |t|
    t.string 'number',           limit: 255
    t.integer 'criminal_code_id', limit: 4
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'slug',             limit: 255
  end

  add_index 'articles', ['criminal_code_id'], name: 'index_articles_on_criminal_code_id', using: :btree
  add_index 'articles', ['number'], name: 'index_articles_on_number', using: :btree
  add_index 'articles', ['slug'], name: 'index_articles_on_slug', using: :btree

  create_table 'charges', force: :cascade do |t|
    t.integer 'incident_id', limit: 4
    t.integer 'article_id',  limit: 4
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'charges', ['article_id'], name: 'index_charges_on_article_id', using: :btree
  add_index 'charges', ['incident_id'], name: 'index_charges_on_incident_id', using: :btree

  create_table 'criminal_code_translations', force: :cascade do |t|
    t.integer 'criminal_code_id', limit: 4,   null: false
    t.string 'locale',           limit: 255, null: false
    t.datetime 'created_at',                   null: false
    t.datetime 'updated_at',                   null: false
    t.string 'name',             limit: 255
  end

  add_index 'criminal_code_translations', ['criminal_code_id'], name: 'index_criminal_code_translations_on_criminal_code_id', using: :btree
  add_index 'criminal_code_translations', ['locale'], name: 'index_criminal_code_translations_on_locale', using: :btree

  create_table 'criminal_codes', force: :cascade do |t|
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'friendly_id_slugs', force: :cascade do |t|
    t.string 'slug',           limit: 255, null: false
    t.integer 'sluggable_id',   limit: 4,   null: false
    t.string 'sluggable_type', limit: 50
    t.string 'scope',          limit: 255
    t.datetime 'created_at'
  end

  add_index 'friendly_id_slugs', %w(slug sluggable_type scope), name: 'index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope', unique: true, using: :btree
  add_index 'friendly_id_slugs', %w(slug sluggable_type), name: 'index_friendly_id_slugs_on_slug_and_sluggable_type', using: :btree
  add_index 'friendly_id_slugs', ['sluggable_id'], name: 'index_friendly_id_slugs_on_sluggable_id', using: :btree
  add_index 'friendly_id_slugs', ['sluggable_type'], name: 'index_friendly_id_slugs_on_sluggable_type', using: :btree

  create_table 'incident_translations', force: :cascade do |t|
    t.integer 'incident_id',            limit: 4,     null: false
    t.string 'locale',                 limit: 255,   null: false
    t.datetime 'created_at',                           null: false
    t.datetime 'updated_at',                           null: false
    t.text 'description_of_arrest',  limit: 65_535
    t.text 'description_of_release', limit: 65_535
  end

  add_index 'incident_translations', ['incident_id'], name: 'index_incident_translations_on_incident_id', using: :btree
  add_index 'incident_translations', ['locale'], name: 'index_incident_translations_on_locale', using: :btree

  create_table 'incidents', force: :cascade do |t|
    t.integer 'prisoner_id',                limit: 4
    t.date 'date_of_arrest'
    t.text 'old_description_of_arrest',  limit: 65_535
    t.integer 'prison_id',                  limit: 4
    t.date 'date_of_release'
    t.text 'old_description_of_release', limit: 65_535
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'incidents', ['date_of_arrest'], name: 'index_incidents_on_date_of_arrest', using: :btree
  add_index 'incidents', ['date_of_release'], name: 'index_incidents_on_date_of_release', using: :btree
  add_index 'incidents', ['prison_id'], name: 'index_incidents_on_prison_id', using: :btree
  add_index 'incidents', ['prisoner_id'], name: 'index_incidents_on_prisoner_id', using: :btree

  create_table 'incidents_tags', id: false, force: :cascade do |t|
    t.integer 'incident_id', limit: 4
    t.integer 'tag_id',      limit: 4
  end

  add_index 'incidents_tags', ['incident_id'], name: 'index_incidents_tags_on_incident_id', using: :btree
  add_index 'incidents_tags', ['tag_id'], name: 'index_incidents_tags_on_tag_id', using: :btree

  create_table 'page_section_translations', force: :cascade do |t|
    t.integer 'page_section_id', limit: 4,     null: false
    t.string 'locale',          limit: 255,   null: false
    t.datetime 'created_at',                    null: false
    t.datetime 'updated_at',                    null: false
    t.string 'label',           limit: 255
    t.text 'content',         limit: 65_535
  end

  add_index 'page_section_translations', ['locale'], name: 'index_page_section_translations_on_locale', using: :btree
  add_index 'page_section_translations', ['page_section_id'], name: 'index_page_section_translations_on_page_section_id', using: :btree

  create_table 'page_sections', force: :cascade do |t|
    t.string 'name',       limit: 255
    t.datetime 'created_at',             null: false
    t.datetime 'updated_at',             null: false
  end

  create_table 'prison_translations', force: :cascade do |t|
    t.integer 'prison_id',   limit: 4,     null: false
    t.string 'locale',      limit: 255,   null: false
    t.datetime 'created_at',                null: false
    t.datetime 'updated_at',                null: false
    t.string 'name',        limit: 255
    t.text 'description', limit: 65_535
  end

  add_index 'prison_translations', ['locale'], name: 'index_prison_translations_on_locale', using: :btree
  add_index 'prison_translations', ['prison_id'], name: 'index_prison_translations_on_prison_id', using: :btree

  create_table 'prisoner_translations', force: :cascade do |t|
    t.integer 'prisoner_id', limit: 4,   null: false
    t.string 'locale',      limit: 255, null: false
    t.datetime 'created_at',              null: false
    t.datetime 'updated_at',              null: false
    t.string 'name',        limit: 255
  end

  add_index 'prisoner_translations', ['locale'], name: 'index_prisoner_translations_on_locale', using: :btree
  add_index 'prisoner_translations', ['prisoner_id'], name: 'index_prisoner_translations_on_prisoner_id', using: :btree

  create_table 'prisoners', force: :cascade do |t|
    t.string 'old_name',              limit: 255
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'portrait_file_name',    limit: 255
    t.string 'portrait_content_type', limit: 255
    t.integer 'portrait_file_size',    limit: 4
    t.datetime 'portrait_updated_at'
    t.boolean 'currently_imprisoned',  limit: 1
    t.string 'slug',                  limit: 255
    t.date 'date_of_birth'
    t.integer 'gender_id',             limit: 4,   default: 2
  end

  add_index 'prisoners', ['gender_id'], name: 'index_prisoners_on_gender_id', using: :btree
  add_index 'prisoners', ['old_name'], name: 'index_prisoners_on_old_name', using: :btree
  add_index 'prisoners', ['slug'], name: 'index_prisoners_on_slug', using: :btree

  create_table 'prisons', force: :cascade do |t|
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'slug',       limit: 255
  end

  add_index 'prisons', ['slug'], name: 'index_prisons_on_slug', using: :btree

  create_table 'roles', force: :cascade do |t|
    t.string 'name',       limit: 255
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'roles', ['name'], name: 'index_roles_on_name', using: :btree

  create_table 'tag_translations', force: :cascade do |t|
    t.integer 'tag_id',      limit: 4,     null: false
    t.string 'locale',      limit: 255,   null: false
    t.datetime 'created_at',                null: false
    t.datetime 'updated_at',                null: false
    t.string 'name',        limit: 255
    t.text 'description', limit: 65_535
  end

  add_index 'tag_translations', ['locale'], name: 'index_tag_translations_on_locale', using: :btree
  add_index 'tag_translations', ['tag_id'], name: 'index_tag_translations_on_tag_id', using: :btree

  create_table 'tags', force: :cascade do |t|
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'slug',       limit: 255
  end

  add_index 'tags', ['slug'], name: 'index_tags_on_slug', using: :btree

  create_table 'users', force: :cascade do |t|
    t.string 'email',                  limit: 255, default: '', null: false
    t.string 'encrypted_password',     limit: 255, default: '', null: false
    t.string 'reset_password_token',   limit: 255
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer 'sign_in_count',          limit: 4,   default: 0,  null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string 'current_sign_in_ip',     limit: 255
    t.string 'last_sign_in_ip',        limit: 255
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'role_id',                limit: 4
  end

  add_index 'users', ['email'], name: 'index_users_on_email', unique: true, using: :btree
  add_index 'users', ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true, using: :btree
  add_index 'users', ['role_id'], name: 'index_users_on_role_id', using: :btree
end
