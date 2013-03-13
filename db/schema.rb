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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130313044616) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "phone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "contact_person"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "office_address"
    t.text     "delivery_address"
    t.integer  "town_id"
    t.boolean  "is_deleted",       :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "deliveries", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "creator_id"
    t.date     "delivery_date"
    t.string   "code"
    t.boolean  "is_confirmed",  :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.boolean  "is_finalized",  :default => false
    t.integer  "finalizer_id"
    t.datetime "finalized_at"
    t.boolean  "is_deleted",    :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "delivery_entries", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "employees", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "address"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "items", :force => true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.string   "supplier_code"
    t.string   "customer_code"
    t.integer  "item_category_id"
    t.decimal  "average_cost",              :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "recommended_selling_price", :precision => 11, :scale => 2, :default => 0.0
    t.integer  "ready",                                                    :default => 0
    t.integer  "scrap",                                                    :default => 0
    t.integer  "pending_delivery",                                         :default => 0
    t.integer  "on_delivery",                                              :default => 0
    t.integer  "pending_receival",                                         :default => 0
    t.boolean  "is_deleted",                                               :default => false
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  create_table "purchase_order_entries", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "purchase_order_id"
    t.string   "code"
    t.integer  "item_id"
    t.integer  "quantity"
    t.boolean  "is_fulfilled",      :default => false
    t.boolean  "is_confirmed",      :default => false
    t.boolean  "is_deleted",        :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "purchase_orders", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "vendor_id"
    t.string   "code"
    t.boolean  "is_confirmed", :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.boolean  "is_deleted",   :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "purchase_receival_entries", :force => true do |t|
    t.integer  "creator_id"
    t.string   "code"
    t.integer  "item_id"
    t.integer  "purchase_receival_id"
    t.integer  "purchase_order_entry_id"
    t.integer  "vendor_id"
    t.integer  "quantity",                :default => 0
    t.boolean  "is_confirmed",            :default => false
    t.boolean  "is_deleted",              :default => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "purchase_receivals", :force => true do |t|
    t.integer  "vendor_id"
    t.integer  "creator_id"
    t.date     "receival_date"
    t.string   "code"
    t.boolean  "is_confirmed",  :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.boolean  "is_deleted",    :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "title",       :null => false
    t.text     "description", :null => false
    t.text     "the_role",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "stock_entries", :force => true do |t|
    t.integer  "is_addition",                                         :default => 1
    t.integer  "creator_id"
    t.integer  "source_document_id"
    t.string   "source_document"
    t.integer  "entry_case",                                          :default => 0
    t.integer  "quantity"
    t.integer  "used_quantity",                                       :default => 0
    t.integer  "scrapped_quantity",                                   :default => 0
    t.integer  "item_id"
    t.boolean  "is_finished",                                         :default => false
    t.decimal  "base_price_per_piece", :precision => 12, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
  end

  create_table "stock_migrations", :force => true do |t|
    t.integer  "item_id"
    t.string   "code"
    t.integer  "creator_id"
    t.integer  "quantity"
    t.boolean  "is_confirmed", :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "stock_mutations", :force => true do |t|
    t.integer  "quantity"
    t.integer  "scrap_item_id"
    t.integer  "stock_entry_id"
    t.integer  "creator_id"
    t.integer  "source_document_id"
    t.string   "source_document_entry"
    t.integer  "source_document_entry_id"
    t.string   "source_document"
    t.integer  "mutation_case"
    t.integer  "mutation_status",          :default => 1
    t.integer  "item_status",              :default => 1
    t.integer  "item_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.integer  "role_id"
    t.string   "name"
    t.string   "username"
    t.string   "login"
    t.boolean  "is_deleted",             :default => false
    t.boolean  "is_main_user",           :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vendors", :force => true do |t|
    t.string   "name"
    t.string   "contact_person"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "address"
    t.boolean  "is_deleted",     :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

end
