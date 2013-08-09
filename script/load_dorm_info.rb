#!/usr/bin/ruby

############################################################
#                     SCRIPT NOTES                         #
############################################################
# This This script assumes a certain format that you might #
# have to change. Here is an example entry for reference:  #
#----------------------------------------------------------#
# College                 |       Dorm                     #
#----------------------------------------------------------#
# Stanford University     |       680 Lomita               #
############################################################

RAILS_ENV = 'development'
require File.dirname(__FILE__) + '/../config/environment'

# Require gems AFTER we load the environment so they are found
require 'faster_csv'


# Store up 'college-info.csv'
INFO = ARGV[0] if File.directory?(ARGV[0])

# Here are the column constants
COLLEGE = 0
DORM = 1

# Set up error file
errors = File.open(ARGV[1], "a")
errors.puts "Dorm info database errors"
errors.puts "--------------------------"
no_errors = true

Dir.foreach(INFO) do |filename|
  next unless filename =~ /\.csv$/i
  full_path = File.join(INFO, filename)
  puts "Reading dorm file #{filename}"
  index = 1
  FasterCSV.foreach(full_path) do |row|
    if row[COLLEGE] != "College"
      college = College.find_by_name(row[COLLEGE])
      if college.nil?
        errors.puts "Can't find #{row[COLLEGE]} in database.  Skipping row #{index} in #{INFO}."
        no_errors = false
      else
        dorm = Dorm.find_or_create_by_name_and_college_id(row[DORM], college.id)
      end
    end
    index += 1
  end
end

# Close errors file for now...
errors.puts "--------------------------\n\n"
errors.close

exit 0 if no_errors
exit 1