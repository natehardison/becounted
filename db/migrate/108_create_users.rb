class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.boolean :added_app, :default => false
     
      t.belongs_to :college
      t.belongs_to :dorm
      t.belongs_to :county
      t.belongs_to :home_state
      t.belongs_to :town
      t.belongs_to :voting_state
      t.belongs_to :zip_code
      
      t.integer :points
      t.integer :status_id
      t.integer :voting_method_id
      
      t.string :fb_uid
      
      t.boolean :privacy_enabled, :default => false

      ## Keep track of last active date
      ## This will be in a "History" table
      #t.date :last_activity
      t.timestamps
    end
    add_index :users, :college_id
    add_index :users, :dorm_id
    add_index :users, :county_id
    add_index :users, :fb_uid
    add_index :users, :home_state_id
    add_index :users, :status_id
    add_index :users, :town_id
    add_index :users, :voting_method_id
    add_index :users, :voting_state_id
    add_index :users, :zip_code_id
    add_index :users, :privacy_enabled
  end

  def self.down
    drop_table :users
  end
end
