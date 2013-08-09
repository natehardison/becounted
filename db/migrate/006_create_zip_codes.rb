class CreateZipCodes < ActiveRecord::Migration
  def self.up
    create_table :zip_codes do |t|
      t.string  :zip_code,  :null => false
    end
    add_index :zip_codes, :zip_code
  end

  def self.down
    drop_table :zip_codes
  end
end
