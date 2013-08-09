class CreateAbsenteeHurdles < ActiveRecord::Migration
  def self.up
    create_table :absentee_hurdles do |t|
      t.belongs_to :state
      
      t.string :title, :null => false, :limit => 568
      t.string :part_1, :limit => 525
      t.string :part_2, :limit => 525
      t.string :part_3, :limit => 525
      t.string :part_4, :limit => 525
      t.string :part_5, :limit => 525
      t.string :part_6, :limit => 525
      t.string :part_7, :limit => 525
      t.string :part_8, :limit => 525
      t.string :part_9, :limit => 525
      t.string :part_10, :limit => 525
      t.string :part_11, :limit => 525
      t.string :part_12, :limit => 525
    end
    add_index :absentee_hurdles, :state_id
  end

  def self.down
    drop_table :absentee_hurdles
  end
end
