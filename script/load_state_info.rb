#!/usr/bin/ruby

######################################################################
#                         SCRIPT NOTES                               #
######################################################################
# This script assumes a certain format that you might have to change.#
# Here is an example entry for reference:                            #
#--------------------------------------------------------------------#
# ABBREV | COMP | VOTE_TYPE | ADDR 1 | ... | CITY | ZIP | VOTING REQ #
#--------|------|-----------|--------|-----|------|-----|------------#
#  AL    |  20  |  COUNTY   |Sec. Ste|     |Birmin|12345|Be a citizen#
#  AK    |  49  |   TOWN    |Dan Nye |1 2nd|Juneau|56789|  No jail!  #
#--------------------------------------------------------------------#
######################################################################

RAILS_ENV = 'development'
require File.dirname(__FILE__) + '/../config/environment'

# Require gems AFTER we load the environment so they are found
require 'faster_csv'

# Open up 'state-info.csv'
INFO = ARGV[0] if File.file?(ARGV[0])

# These are the column constants
CODE      = 0
COMP      = 1
VOTE_TYPE = 2
ADDR_1    = 3
ADDR_2    = 4
ADDR_3    = 5
ADDR_4    = 6
ADDR_5    = 7
CITY      = 8
ZIP       = 9

VOTING_REQ_START = 10
# Assume next columns are voting requirements
NUM_VOTING_REQS = 7

REG_DEADLINE = 17
REG_DEADLINE_INFO = 18
ABS_START = 19
ABS_END = 20
ELECTION_DAY = Date.new(2008, 11, 4)

# Set up error file
errors = File.open(ARGV[1], "a")
errors.puts "State info database errors"
errors.puts "--------------------------"
no_errors = true

index = 1
max_length = 0
FasterCSV.foreach(INFO) do |row|
  if row[CODE] != "STATE"
    state = State.find_by_code(row[CODE])
    if state.nil?
      errors.puts "Can't find #{row[CODE]} in database.  Skipping row #{index}."
      no_errors = false
    else
      state.competitive = row[COMP]
      state.votes_by_county = (row[VOTE_TYPE] == 'COUNTY')
      #need to check for nulls!!!
      row[ZIP] = row[ZIP].rjust(5, "0") unless row[ZIP].nil?
      address = Address.find_or_create_by_line_1_and_line_2_and_line_3_and_line_4_and_line_5_and_city_and_state_and_zip(row[ADDR_1], row[ADDR_2], row[ADDR_3], row[ADDR_4], row[ADDR_5], row[CITY], row[CODE], row[ZIP])
      state.address = address
      NUM_VOTING_REQS.times do |i|
        unless row[VOTING_REQ_START + i].nil?
          max_length = row[VOTING_REQ_START + i].length if row[VOTING_REQ_START].length > max_length
          req = VotingReq.find_or_create_by_req(row[VOTING_REQ_START + i])
          state.voting_reqs << req
        end
      end
      state.reg_deadline = ELECTION_DAY - row[REG_DEADLINE].to_i unless row[REG_DEADLINE].nil?
      state.reg_deadline_info = row[REG_DEADLINE_INFO]
      state.abs_request_deadline = row[ABS_START]
      state.abs_closing_deadline = row[ABS_END]
      state.save!
    end
  end
  index += 1
end

puts "Max voting req length: #{max_length}"

# Close errors file for now...
errors.puts "--------------------------\n\n"
errors.close

exit 0 if no_errors
exit 1
