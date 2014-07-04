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

ActiveRecord::Schema.define(version: 20140704031741) do

  create_table "fulfillment_services", force: true do |t|
    t.string "username_encrypted"
    t.string "password_encrypted"
    t.string "shop"
  end

  add_index "fulfillment_services", ["shop"], name: "index_fulfillment_services_on_shop"

  create_table "shops", force: true do |t|
    t.string "name"
    t.string "token_encrypted"
  end

  add_index "shops", ["name"], name: "index_shops_on_name"

end
