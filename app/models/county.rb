class County < ActiveRecord::Base
  belongs_to :address
  belongs_to :state
  
  has_many :locations
  has_many :towns
  has_many :users
  has_many :zip_codes, :through => :locations
  
  validates_uniqueness_of :name, :scope => :state_id
  
end
