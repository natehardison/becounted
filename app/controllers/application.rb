# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  # TODO: Check this out at:
  # http://blog.ror.com.my/2007/11/28/facebook-rails-gotchas-csrf-protection-and-cookie-session-store/
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => '1cd6f5719b07f4a60e2b3314822aeeda'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  before_filter :require_login
  before_filter :import_user
  after_filter :add_achievements_to_minifeed
  
  # We're trying to avoid using Facebooker as much as possible to avoid those
  # pesky API calls that slow down the app.
  def import_user
    fb_uid = facebook_params[:user]
    @user = User.find_or_create_by_fb_uid(fb_uid)
    @user.session_key = facebook_params[:session_key]
    # if we are here, the user is using our app, so they are an app user
    if @user.status == Status::Invited
      @user.status = Status::AddedApplication
    end
    return true
  end
  
  def add_achievements_to_minifeed
    pending_achievements = Achievement.find(:all,
                                            :conditions => {:user_id => @user.id, :added_to_minifeed => false},
                                            :order => 'created_at ASC',
                                            :limit => MAX_ACHIEVEMENTS_TO_POST_AT_ONCE)
    pending_achievements.each() do |achievement|
      achievement.update_attributes(:added_to_minifeed => true)
    end
    #TODO see why fork screws up things
    #TODO if you are having mysql gone away problems (<body> thing), maybe it's in the fork
    #TODO to fix this, make sure no database calls happen after the fork!!!
    #Process.fork do
      pending_achievements.each() do |achievement|
        begin
          data = {}
          #TODO make these next three lines real
          data = achievement.feed_data
          targets = []
          body_general = ''
          # Turn on when ready to launch
          #facebook_session.publish_user_action(FACEBOOK_FEED_TEMPLATE_ID, data, targets, body_general)
        rescue Exception => e
          logger.error 'Could not create feed message'
          logger.error e.inspect
        end
      end
#    end
    return true
  end
  
end
