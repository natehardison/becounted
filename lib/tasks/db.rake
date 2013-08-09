namespace :db do
  
  desc "Drops, recreates, and reloads the whole database"
  task :reload => [:environment, :drop, :create, :migrate, :load]
  
  desc "Load the BeCounted database"
  task :load => [:environment, "db:load:config", "db:load:towns", "db:load:dorms"] do
  end
  
  # TODO: Make it so these aren't dependent on each other (i.e. make it possible
  # to do 'rake db:load:counties').  This probably means they all have to depend
  # on :environment and :config.  This should check to see if the other files are 
  # already loaded (like the zip codes, which takes forever).
  # TODO: Add error checking and notifications.
  namespace :load do
    
    desc 'Configure the file paths that will be used in loading'
    task :config do
      # Update all of the data file names/paths in the yml file
      data_files = File.join(RAILS_ROOT, 'config', 'data_files.yml')
      DATA = YAML.load_file(data_files)
      data_dir= File.join(RAILS_ROOT, DATA['directory'])
      @error_log = File.join(data_dir, DATA['error_log'])
      @zip_1 = File.join(data_dir, DATA['zip_codes'][1])
      @zip_2 = File.join(data_dir, DATA['zip_codes'][2])
      @zip_multi = File.join(data_dir, DATA['zip_codes'][3])
      @state_info = File.join(data_dir, DATA['state_info'])
      @county_info = File.join(data_dir, DATA['county_info'])
      @town_info = File.join(data_dir, DATA['town_info'])
      @college_info = File.join(data_dir, DATA['college_info'])
      @dorm_info = File.join(data_dir, DATA['dorm_info'])
      
      #Clear out the error file
      FileUtils.rm(@error_log)
      FileUtils.touch(@error_log)
    end
    
    desc 'Load the college info into the database.'
    task :colleges => [:config, :states] do
      puts 'Loading college info...'
      `ruby script/load_college_info.rb #{@college_info} #{@error_log}`
      puts 'College info loaded.'
    end
    
    desc 'Load the dorm info into the database.'
    task :dorms => [:config, :colleges] do
      puts 'Loading dorm info...'
      `ruby script/load_dorm_info.rb #{@dorm_info} #{@error_log}`
      puts 'Dorm info loaded.'
    end
    
    desc 'Load the dorm info into the database without loading prereqs.'
    task :newdorms => [:config] do
      puts 'Loading dorm info...'
      `ruby script/load_dorm_info.rb #{@dorm_info} #{@error_log}`
      puts 'Dorm info loaded.'
    end
    
    desc 'Load the town info into the database.'
    task :towns => [:config, :counties] do
      puts 'Loading town info...'
      `ruby script/load_town_info.rb #{@town_info} #{@error_log}`
      puts 'Town info loaded.'
    end
    
    desc 'Load the county info into the database.'
    task :counties => [:config, :states] do
      puts 'Loading county info...'
      `ruby script/load_county_info.rb #{@county_info} #{@error_log}`
      puts 'County info loaded.'
    end
    
    desc 'Load the state info into the database.'
    task :states => [:config, :zip_codes] do
      puts 'Loading the state info now...'
      `ruby script/load_state_info.rb #{@state_info} #{@error_log}`
      puts 'State info loaded.'
    end
    
    desc 'Load the zip code info into the database.'
    task :zip_codes => :config do
      puts 'Starting to load the zip codes...'
      time = Time.now
      `ruby script/load_zip_codes.rb #{@zip_1} #{@zip_2} #{@zip_multi} #{@error_log}`
      time = (Time.now - time).to_i
      puts "Now we're done loading zip codes! It took #{(time / 60)} minutes and #{(time % 60)} seconds"
    end
  end
end
