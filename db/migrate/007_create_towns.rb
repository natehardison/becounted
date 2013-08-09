class CreateTowns < ActiveRecord::Migration
  def self.up
    create_table :towns do |t|
      t.string :name, :null => false
      t.string :phone
      t.string :fax
      t.string :email
      t.string :contact_name

      t.integer :address_id
      #belongs to a county
      t.integer :county_id, :null => false
    end
    add_index :towns, :county_id
  end

  def self.down
    drop_table :towns
  end
end
