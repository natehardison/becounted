class CreateActiveDates < ActiveRecord::Migration
  def self.up
    create_table :active_dates, :id => false do |t|
      t.integer :user_id
      t.timestamps
    end
    add_index :active_dates, :user_id
    add_index :active_dates, :created_at
  end

  def self.down
    drop_table :active_dates
  end
end
