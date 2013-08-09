class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.integer :zip_code_id #:null => false
      
      t.string :line_1 #:null => false
      t.string :line_2
      t.string :line_3
      t.string :line_4
      t.string :line_5
      t.string :city #:null => false
      t.string :state, :limit => 2 #:null => false
      t.string :zip, :limit => 10 #:null => false
    end
  end

  def self.down
    drop_table :addresses
  end
end
