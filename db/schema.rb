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

ActiveRecord::Schema.define(version: 3) do

  create_table "missions", force: true do |t|
    t.string   "name"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
  end

  add_index "missions", ["creator_id"], name: "index_missions_on_creator_id"

  create_table "participants", force: true do |t|
    t.integer  "mission_id"
    t.integer  "user_id"
    t.string   "role"
    t.integer  "slot_id"
    t.datetime "joined_at"
    t.boolean  "is_mission_admin"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password"
    t.datetime "last_signed_in_on"
    t.datetime "signed_up_on"
    t.boolean  "is_admin"
  end

end
