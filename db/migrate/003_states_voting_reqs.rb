class StatesVotingReqs < ActiveRecord::Migration
  def self.up
    create_table :states_voting_reqs, :id => false do |t|
      t.integer :state_id, :null => false
      t.integer :voting_req_id, :null => false
    end
    add_index :states_voting_reqs, :state_id
    add_index :states_voting_reqs, :voting_req_id  
  end
  
  def self.down
    drop_table :states_voting_reqs
  end
end
