class State < ActiveRecord::Base
  belongs_to :address
  
  has_many :absentee_hurdles
  has_many :colleges
  has_many :counties
  has_many :residents, :class_name => 'User', :foreign_key => 'home_state_id'
  has_many :voters, :class_name => 'User', :foreign_key => 'voting_state_id'
 
  has_and_belongs_to_many :voting_reqs
  
  validates_uniqueness_of :code
  
  def is_more_competitive_than?(other_state)
    self[:competitive] < other_state[:competitive]
  end
  
  def votes_by_county?
    self[:votes_by_county]
  end
  
  def votes_by_town?
    !self.votes_by_county?
  end
  
end
