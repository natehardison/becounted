class HomeController < ApplicationController
  skip_before_filter :import_user, :only => [:about]
  skip_filter :add_achievements_to_minifeed, :only => [:about]
  
  def index
    if @user.status_id < Status::RegistrationNotStarted::ID
      redirect_to :controller => 'walkthrough'
    else
      redirect_to :controller => 'vote'
    end
  end
  
  def about
    render :action => 'about'
  end
  
  def error
    render :action => 'error'
  end
  
  def help
    render :action => 'help'
  end
  
  def post_authorize
    redirect_to :action => 'index'
  end
  
  def post_remove
    @user.update_attributes(:added_app => false) unless @user.nil?
    render :nothing => true
  end

  def privacy
    render :action => 'privacy'
  end
  
  def save_privacy
    privacy_enabled = (params[:enabled] == '1')
    @user.update_attributes!(:privacy_enabled => privacy_enabled)
    redirect_to :action => 'privacy'
  end
  
  def start_over
    @user.start_over
    @user.save!
    redirect_to :action => 'index'
  end
  
end