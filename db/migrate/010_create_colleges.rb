class CreateColleges < ActiveRecord::Migration
  def self.up
    create_table :colleges do |t|
      t.integer :state_id, :null => false
      t.string :name, :null => false
    end
    add_index :colleges, :state_id
    add_index :colleges, :name
  end

  def self.down
    drop_table :colleges
  end
end
