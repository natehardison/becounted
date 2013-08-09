class Location < ActiveRecord::Base
  belongs_to :county
  belongs_to :town
  belongs_to :zip_code
  
  #validates_uniqueness_of :
end
