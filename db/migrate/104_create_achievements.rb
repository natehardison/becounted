class CreateAchievements < ActiveRecord::Migration
  def self.up
    create_table :achievements do |t|
      t.belongs_to :user
      t.integer :action_id, :null => false
      t.boolean :added_to_minifeed, :default => false
      t.timestamps
    end
    add_index :achievements, :user_id
  end

  def self.down
    drop_table :achievements
  end
end
