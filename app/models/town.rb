class Town < ActiveRecord::Base
  belongs_to :address
  belongs_to :county
  
  has_many :locations
  has_many :zip_codes, :through => :locations
  has_many :users
  
  validates_uniqueness_of :name, :scope => :county_id
end
