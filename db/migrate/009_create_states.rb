class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.boolean :votes_by_county, :default => true
      
      t.date :abs_request_deadline
      t.date :abs_closing_deadline
      t.date :reg_deadline
      
      t.integer :address_id
      t.integer :competitive, :limit => 2, :default => 1
     
      t.string :code, :limit => 2, :null => false
      t.string :name, :null => false
      t.string :reg_deadline_info
    end
  end

  def self.down
    drop_table :states
  end
end
