class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :invitor_id, :null => false
      t.integer :invitee_id, :null => false
      t.boolean :accepted, :null => false, :default => false
      t.timestamps
    end
    add_index :invitations, [:invitor_id, :invitee_id], :unique => true
    add_index :invitations, :invitee_id
  end

  def self.down
    drop_table :invitations
  end
end
