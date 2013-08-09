require 'erb'
require 'config/accelerator/accelerator_tasks'
 
set :application, "becounted" #matches names used in smf_template.erb
set :repository,  "http://becounted.unfuddle.com/svn/becounted_bcsvn/trunk"
 
# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "var/www/apps/#{application}" # I like this location
 
set :user, 'db640099'
set :runner, 'db640099'
 
# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :subversion
# set :scm_command, "/opt/local/bin/svn"
# set :local_scm_command, :default
 
# keep a cached code checkout on the server, and do updates each time (more efficient)
set :deploy_via, :remote_cache
 
# Set the path to svn and rake if needed(Does not seem to be necessary on the newpkgsrc templated accelerators, but if needed change path to /opt/local/bin/ )
# set :svn, "/opt/csw/bin/svn"
# set :rake, "/opt/csw/bin/rake"
 
 
set :domain, 'db640099.fb.joyent.us'
 
role :app, domain
role :web, domain
role :db,  domain, :primary => true
 
set :server_name, "db640099.fb.joyent.us"
set :server_alias, "*.db640099.fb.joyent.us"
 
deploy.task :restart do
  accelerator.smf_restart
  accelerator.restart_apache
end
 
deploy.task :start do
  accelerator.smf_start
  accelerator.restart_apache
end
 
deploy.task :stop do
  accelerator.smf_stop
  accelerator.restart_apache
end
 
after :deploy, 'deploy:cleanup'