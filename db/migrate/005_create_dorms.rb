class CreateDorms < ActiveRecord::Migration
  def self.up
    create_table :dorms do |t|
      t.string :name
      t.string :college_id
    end
    add_index :dorms, :college_id
  end

  def self.down
    drop_table :dorms
  end
end
