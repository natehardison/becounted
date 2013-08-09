class Invitation < ActiveRecord::Base
  belongs_to :invitor, :class_name => 'User', :foreign_key => 'invitor_id'
  belongs_to :invitee, :class_name => 'User', :foreign_key => 'invitee_id'
  validates_uniqueness_of :invitor_id, :scope => :invitee_id
end
