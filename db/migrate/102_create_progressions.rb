class CreateProgressions < ActiveRecord::Migration
  def self.up
    create_table :progressions, :id => false do |t|
      t.integer :user_id, :null => false
      t.integer :status_id, :null => false
      t.timestamps
    end
    add_index :progressions, :user_id
    add_index :progressions, :status_id
    add_index :progressions, :created_at
  end

  def self.down
    drop_table :progressions
  end
end
