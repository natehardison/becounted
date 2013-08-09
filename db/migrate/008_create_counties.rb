class CreateCounties < ActiveRecord::Migration
  def self.up
    create_table :counties do |t|
      t.string :name, :null => false
      t.string :phone
      t.string :fax
      t.string :email
      t.string :contact_name

      t.integer :address_id
      #belongs to a state
      t.integer :state_id, :null => false
    end
    add_index :counties, :state_id
  end

  def self.down
    drop_table :counties
  end
end
