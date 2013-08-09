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

ActiveRecord::Schema.define(:version => 201) do

  create_table "absentee_hurdles", :force => true do |t|
    t.integer "state_id", :limit => 11
    t.string  "title",    :limit => 568, :null => false
    t.string  "part_1",   :limit => 525
    t.string  "part_2",   :limit => 525
    t.string  "part_3",   :limit => 525
    t.string  "part_4",   :limit => 525
    t.string  "part_5",   :limit => 525
    t.string  "part_6",   :limit => 525
    t.string  "part_7",   :limit => 525
    t.string  "part_8",   :limit => 525
    t.string  "part_9",   :limit => 525
    t.string  "part_10",  :limit => 525
    t.string  "part_11",  :limit => 525
    t.string  "part_12",  :limit => 525
  end

  add_index "absentee_hurdles", ["state_id"], :name => "index_absentee_hurdles_on_state_id"

  create_table "achievements", :force => true do |t|
    t.integer  "user_id",           :limit => 11
    t.integer  "action_id",         :limit => 11,                    :null => false
    t.boolean  "added_to_minifeed",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "achievements", ["user_id"], :name => "index_achievements_on_user_id"

  create_table "active_dates", :id => false, :force => true do |t|
    t.integer  "user_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_dates", ["user_id"], :name => "index_active_dates_on_user_id"
  add_index "active_dates", ["created_at"], :name => "index_active_dates_on_created_at"

  create_table "addresses", :force => true do |t|
    t.integer "zip_code_id", :limit => 11
    t.string  "line_1"
    t.string  "line_2"
    t.string  "line_3"
    t.string  "line_4"
    t.string  "line_5"
    t.string  "city"
    t.string  "state",       :limit => 2
    t.string  "zip",         :limit => 10
  end

  create_table "colleges", :force => true do |t|
    t.integer "state_id", :limit => 11, :null => false
    t.string  "name",                   :null => false
  end

  add_index "colleges", ["state_id"], :name => "index_colleges_on_state_id"
  add_index "colleges", ["name"], :name => "index_colleges_on_name"

  create_table "counties", :force => true do |t|
    t.string  "name",                       :null => false
    t.string  "phone"
    t.string  "fax"
    t.string  "email"
    t.string  "contact_name"
    t.integer "address_id",   :limit => 11
    t.integer "state_id",     :limit => 11, :null => false
  end

  add_index "counties", ["state_id"], :name => "index_counties_on_state_id"

  create_table "dorms", :force => true do |t|
    t.string "name"
    t.string "college_id"
  end

  add_index "dorms", ["college_id"], :name => "index_dorms_on_college_id"

  create_table "invitations", :force => true do |t|
    t.integer  "invitor_id", :limit => 11,                    :null => false
    t.integer  "invitee_id", :limit => 11,                    :null => false
    t.boolean  "accepted",                 :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["invitor_id", "invitee_id"], :name => "index_invitations_on_invitor_id_and_invitee_id", :unique => true
  add_index "invitations", ["invitee_id"], :name => "index_invitations_on_invitee_id"

  create_table "locations", :id => false, :force => true do |t|
    t.integer "county_id",   :limit => 11, :null => false
    t.integer "town_id",     :limit => 11
    t.integer "zip_code_id", :limit => 11, :null => false
  end

  add_index "locations", ["county_id"], :name => "index_locations_on_county_id"
  add_index "locations", ["zip_code_id"], :name => "index_locations_on_zip_code_id"

  create_table "progressions", :id => false, :force => true do |t|
    t.integer  "user_id",    :limit => 11, :null => false
    t.integer  "status_id",  :limit => 11, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "progressions", ["user_id"], :name => "index_progressions_on_user_id"
  add_index "progressions", ["status_id"], :name => "index_progressions_on_status_id"
  add_index "progressions", ["created_at"], :name => "index_progressions_on_created_at"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "states", :force => true do |t|
    t.boolean "votes_by_county",                    :default => true
    t.date    "abs_request_deadline"
    t.date    "abs_closing_deadline"
    t.date    "reg_deadline"
    t.integer "address_id",           :limit => 11
    t.integer "competitive",          :limit => 2,  :default => 1
    t.string  "code",                 :limit => 2,                    :null => false
    t.string  "name",                                                 :null => false
    t.string  "reg_deadline_info"
  end

  create_table "states_voting_reqs", :id => false, :force => true do |t|
    t.integer "state_id",      :limit => 11, :null => false
    t.integer "voting_req_id", :limit => 11, :null => false
  end

  add_index "states_voting_reqs", ["state_id"], :name => "index_states_voting_reqs_on_state_id"
  add_index "states_voting_reqs", ["voting_req_id"], :name => "index_states_voting_reqs_on_voting_req_id"

  create_table "towns", :force => true do |t|
    t.string  "name",                       :null => false
    t.string  "phone"
    t.string  "fax"
    t.string  "email"
    t.string  "contact_name"
    t.integer "address_id",   :limit => 11
    t.integer "county_id",    :limit => 11, :null => false
  end

  add_index "towns", ["county_id"], :name => "index_towns_on_county_id"

  create_table "users", :force => true do |t|
    t.boolean  "added_app",                      :default => false
    t.integer  "college_id",       :limit => 11
    t.integer  "dorm_id",          :limit => 11
    t.integer  "county_id",        :limit => 11
    t.integer  "home_state_id",    :limit => 11
    t.integer  "town_id",          :limit => 11
    t.integer  "voting_state_id",  :limit => 11
    t.integer  "zip_code_id",      :limit => 11
    t.integer  "points",           :limit => 11
    t.integer  "status_id",        :limit => 11
    t.integer  "voting_method_id", :limit => 11
    t.string   "fb_uid"
    t.boolean  "privacy_enabled",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["college_id"], :name => "index_users_on_college_id"
  add_index "users", ["dorm_id"], :name => "index_users_on_dorm_id"
  add_index "users", ["county_id"], :name => "index_users_on_county_id"
  add_index "users", ["fb_uid"], :name => "index_users_on_fb_uid"
  add_index "users", ["home_state_id"], :name => "index_users_on_home_state_id"
  add_index "users", ["status_id"], :name => "index_users_on_status_id"
  add_index "users", ["town_id"], :name => "index_users_on_town_id"
  add_index "users", ["voting_method_id"], :name => "index_users_on_voting_method_id"
  add_index "users", ["voting_state_id"], :name => "index_users_on_voting_state_id"
  add_index "users", ["zip_code_id"], :name => "index_users_on_zip_code_id"
  add_index "users", ["privacy_enabled"], :name => "index_users_on_privacy_enabled"

  create_table "voting_reqs", :force => true do |t|
    t.string "req", :limit => 400, :null => false
  end

  create_table "zip_codes", :force => true do |t|
    t.string "zip_code", :null => false
  end

  add_index "zip_codes", ["zip_code"], :name => "index_zip_codes_on_zip_code"

end
