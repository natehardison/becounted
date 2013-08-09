class ZipCode < ActiveRecord::Base  
  has_many :counties, :through => :locations
  has_many :locations
  has_many :towns, :through => :locations
  has_many :users
  
  validates_uniqueness_of :zip_code
  
  def is_in?(state)
    self.counties.each do |county|
      return true if county.state == state
    end
    false
  end
end
