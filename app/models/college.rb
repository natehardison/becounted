class College < ActiveRecord::Base
  belongs_to :state
  
  has_many :students, :class_name => 'User', :foreign_key => :college_id
  has_many :dorms
  
  validates_uniqueness_of :name, :scope => :state_id
end