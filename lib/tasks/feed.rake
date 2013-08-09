namespace :feed do
  
  desc "Register Facebook minifeed templates"
  task :register => [:environment] do
    puts `script/runner #{File.join(RAILS_ROOT, 'script', 'register_facebook_feed_template.rb')}`
  end
  
end
