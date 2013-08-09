#!/usr/bin/ruby

RAILS_ENV = 'development'
require File.dirname(__FILE__) + '/../config/environment'

# Require gems AFTER we load the environment so they are found
require 'faster_csv'

INFO = ARGV[0]

NAME         = 0 
STATE        = 1
ADDR_1       = 2
ADDR_2       = 3
ADDR_3       = 4
ADDR_4       = 5
ADDR_5       = 6
CITY         = 7
ZIP          = 8
PHONE        = 9
## NOT USED ANYMORE ##
CONTACT_NAME = 10
FAX          = 11
EMAIL        = 12

# Set up error file
errors = File.open(ARGV[1], "a")
errors.puts "County info database errors"
errors.puts "---------------------------"
no_errors = true

index = 1
FasterCSV.foreach(INFO) do |row|
  if row[STATE] != "STATE"
    state = State.find_by_code(row[STATE])
    if state.nil?
      errors.puts "Can't find #{row[STATE]} in database.  Skipping row #{index} in #{INFO}."
      no_errors = false
    elsif !row[NAME].nil?
      name = row[NAME].upcase
      county = County.find_by_name_and_state_id(name, state.id)
      if county.nil?
        errors.puts "Can't find #{name}, #{state.code} in database.  Skipping row #{index} in #{INFO}."
        no_errors = false
      else
        row[ZIP] = row[ZIP].rjust(5, "0")  unless row[ZIP].nil?
        address = Address.find_or_create_by_line_1_and_line_2_and_line_3_and_line_4_and_line_5_and_city_and_state_and_zip(row[ADDR_1], row[ADDR_2], row[ADDR_3], row[ADDR_4], row[ADDR_5], row[CITY], row[STATE], row[ZIP])
        county.address_id = address.id
        county.phone = row[PHONE]
#        county.fax = row[FAX]
#        county.email = row[EMAIL]
#        county.contact_name = row[CONTACT_NAME]
        county.save!
      end
    end
  end
  index += 1
end

# Close errors file for now...
errors.puts "---------------------------\n\n"
errors.close

exit 0 if no_errors
exit 1
