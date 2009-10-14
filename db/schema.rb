# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091006183434) do

  create_table "features", :force => true do |t|
    t.integer  "sound_id"
    t.string   "feature_type"
    t.text     "trajectory"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", :force => true do |t|
    t.integer  "first_id"
    t.integer  "second_id"
    t.string   "first_type"
    t.string   "second_type"
    t.float    "cost",        :default => 0.0
    t.float    "distance",    :default => 0.0
    t.string   "context"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["cost"], :name => "index_links_on_cost"
  add_index "links", ["first_id", "cost"], :name => "index_links_on_first_id_and_cost"
  add_index "links", ["first_id", "second_id"], :name => "index_links_on_first_id_and_second_id"
  add_index "links", ["first_id"], :name => "index_links_on_first_id"
  add_index "links", ["second_id"], :name => "index_links_on_second_id"

  create_table "settings", :force => true do |t|
    t.string   "var",        :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sounds", :force => true do |t|
    t.string   "filename"
    t.string   "content_type"
    t.integer  "size"
    t.text     "description"
    t.datetime "recorded_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "samples"
    t.integer  "sample_rate"
    t.integer  "frame_size"
    t.integer  "hop_size"
    t.integer  "spectrum_size"
    t.integer  "frames"
    t.decimal  "frame_length",    :precision => 65, :scale => 10
    t.decimal  "hop_length",      :precision => 65, :scale => 10
    t.integer  "soundwalk_id"
    t.integer  "user_id"
    t.integer  "study_coverage"
    t.decimal  "lng",             :precision => 15, :scale => 12
    t.decimal  "lat",             :precision => 15, :scale => 12
    t.float    "self_similarity",                                 :default => 0.0
  end

  create_table "soundwalks", :force => true do |t|
    t.string   "filename"
    t.string   "content_type"
    t.integer  "size"
    t.string   "privacy"
    t.string   "title"
    t.text     "description"
    t.text     "locations"
    t.decimal  "lat",          :precision => 15, :scale => 12
    t.decimal  "lng",          :precision => 15, :scale => 12
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.decimal  "secret"
    t.boolean  "admin",                                    :default => false
    t.boolean  "can_upload",                               :default => true
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
