# Credit for this goes to http://errtheblog.com/posts/31-rake-around-the-rosie

def sh_mysql(config, command)
  returning '' do |mysql|
    mysql << command << ' '
    mysql << "-u#{config['username']} " if config['username']
    mysql << "-p#{config['password']} " if config['password']
    mysql << "-h#{config['host']} "     if config['host']
    mysql << "-P#{config['port']} "     if config['port']
    mysql << config['database']         if config['database']
#    mysql << 
  end
end

desc "Launch mysql shell.  Use with an environment task (e.g. rake production mysql)" 
task :mysql do
  system sh_mysql(YAML.load(open(File.join('config', 'database.yml')))[RAILS_ENV], 'mysql')
end

namespace :mysql do 
  desc "Dump database to a SQL file"
  task :dump do
    system sh_mysql(YAML.load(open(File.join('config', 'database.yml')))[RAILS_ENV], 'mysqldump')
  end
end
