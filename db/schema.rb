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

ActiveRecord::Schema.define(version: 20140418201950) do

  create_table "fulfillment_services", force: true do |t|
    t.integer "shop_id"
    t.string  "username_encrypted"
    t.string  "password_encrypted"
  end

  add_index "fulfillment_services", ["shop_id"], name: "index_fulfillment_services_on_shop_id"

  create_table "shops", force: true do |t|
    t.string "shop"
    t.string "token_encrypted"
  end

  add_index "shops", ["shop"], name: "index_shops_on_shop"

end
