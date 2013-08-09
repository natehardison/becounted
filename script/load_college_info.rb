#!/usr/bin/ruby

############################################################
#                     SCRIPT NOTES                         #
############################################################
# This This script assumes a certain format that you might #
# have to change. Here is an example entry for reference:  #
#----------------------------------------------------------#
# ABBREV |                COLLEGE NAME                     #
#----------------------------------------------------------#
#  CA    |            Stanford University                  #
#  CA    |        University of California, Berkeley       #
#  ID    |              Boise State University             #
############################################################

RAILS_ENV = 'development'
require File.dirname(__FILE__) + '/../config/environment'

# Require gems AFTER we load the environment so they are found
require 'faster_csv'

# Store up 'college-info.csv'
INFO = ARGV[0] if File.file?(ARGV[0])

# Here are the column constants
STATE = 0
COLLEGE = 1

# Set up error file
errors = File.open(ARGV[1], "a")
errors.puts "College info database errors"
errors.puts "--------------------------"
no_errors = true

index = 1
FasterCSV.foreach(INFO) do |row|
  if row[STATE] != "STATE"
    state = State.find_by_code(row[STATE])
    if state.nil?
      errors.puts "Can't find #{row[STATE]} in database.  Skipping row #{index}."
      no_errors = false
    else
      college = College.find_or_create_by_name_and_state_id(row[COLLEGE], state.id)
    end
  end
  index += 1
end

# Close errors file for now...
errors.puts "--------------------------\n\n"
errors.close

exit 0 if no_errors
exit 1