class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations, :id => false do |t|
      t.references :county, :null => false
      t.references :town
      t.references :zip_code, :null => false
    end
    add_index :locations, :county_id
    add_index :locations, :zip_code_id
  end

  def self.down
    drop_table :locations
  end
end
