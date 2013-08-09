class CreateVotingReqs < ActiveRecord::Migration
  def self.up
    create_table :voting_reqs do |t|
      t.string :req, :null => false, :limit => 400
    end
  end

  def self.down
    drop_table :voting_reqs
  end
end
