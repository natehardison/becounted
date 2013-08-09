RAILS_ENV = 'development'
require File.dirname(__FILE__) + '/../config/environment'

# Require gems AFTER we load the environment so they are found
require 'faster_csv'

# Skip error handling...
ZIP_1     = ARGV[0] if File.file?(ARGV[0])
ZIP_2     = ARGV[1] if File.file?(ARGV[1])
ZIP_MULTI = ARGV[2] if File.file?(ARGV[2])

# Set up error file...
errors = File.open(ARGV[3], "a") if File.file?(ARGV[3])
errors.puts "Zip code database errors"
errors.puts "------------------------"
no_errors = true

# See pdf reference for these numbers
ZIP = 0
# DB has lots of zip code repeats, so each unique zip code
# is denoted by a 'P'.  Testing for this speeds up db loading
# dramatically.
PRIMARY_RECORD = 1
TOWN           = 27
COUNTY         = 29
STATE          = 22
STATE_FULL     = 23
INVALID_STATES = %w{AA AE AP AS FM GU MH MP PR PW VI State}

def parse_db(row)
  #only index 50 states plus D.C.
  unless row[PRIMARY_RECORD] !~ /P/i or INVALID_STATES.include?(row[STATE])
    # Format the zip codes correctly--Excel CSV chops off
    # the leading zeros.
    row[ZIP] = row[ZIP].rjust(5, "0")
    county_name = row[COUNTY].upcase
    town_name = row[TOWN].upcase
    state = State.find_or_create_by_code(:code => row[STATE], :name => row[STATE_FULL])
    county = County.find_or_create_by_name_and_state_id(county_name, state.id)
    town = Town.find_or_create_by_name_and_county_id(town_name, county.id)
    zip = ZipCode.find_or_create_by_zip_code(:zip_code => row[ZIP])
    Location.find_or_create_by_county_id_and_town_id_and_zip_code_id(county.id, town.id, zip.id)
  end
end

FasterCSV.foreach(ZIP_1) do |row|
  parse_db(row)
end

FasterCSV.foreach(ZIP_2) do |row|
  parse_db(row)
end

# New column numbers for these items
STATE_MULTI = 2
COUNTY_MULTI = 4

FasterCSV.foreach(ZIP_MULTI) do |row|
  unless INVALID_STATES.include?(row[STATE_MULTI])
    state = State.find_by_code(row[STATE_MULTI])
    if state.nil?
      errors.puts "Can't find state #{row[STATE_MULTI]} in database!  Skipping zipcode #{row[ZIP]}."
      no_errors = false
    else
      county_name = row[COUNTY_MULTI].upcase
      county = County.find_by_name_and_state_id(county_name, state.id)
      if county.nil?
        errors.puts "Can't find county #{county_name}, #{row[STATE_MULTI]} in database!"
        no_errors = false
      else
        # Format the zip codes correctly--Excel CSV chops off
        # the leading zeros.
        row[ZIP] = row[ZIP].rjust(5, "0")
        zip = ZipCode.find_by_zip_code(row[ZIP])
        if zip.nil?
          puts "WARNING: Couldn't find #{row[ZIP]} in the database!!  Creating it now..."
          zip = ZipCode.create(:zip_code => row[ZIP])
        end
        Location.find_or_create_by_county_id_and_zip_code_id(county.id, zip.id)
      end
    end
  end 	
end

# Close errors file for now...
errors.puts "------------------------\n\n"
errors.close

exit 0 if no_errors
exit 1
