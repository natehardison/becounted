class VotingReq < ActiveRecord::Base
  has_and_belongs_to_many :states
  
  validates_uniqueness_of :req
end
