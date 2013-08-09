class Dorm < ActiveRecord::Base
  belongs_to :college
  has_many :students, :class_name => 'User', :foreign_key => :dorm_id
end
