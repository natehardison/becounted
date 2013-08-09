class VoteController < ApplicationController
  
  before_filter :ensure_walkthrough_complete
  
  def index
    @statuses = @user.get_voting_statuses
    @time_left = (Date.new(2008, 11, 4) - Date.today).to_i
    @voting_method = @user.voting_method
    @voting_state = @user.voting_state
    @college = @user.college
    case @user.status.name
    when 'Status::RegistrationNotStarted'
      begin
        @info = @user.registration_info
      rescue
        @find_location = true
        @info = nil
      end
    when 'Status::AbsenteeNotStarted'
      begin
        @info = @user.absentee_info
      rescue
        @find_location = true
        @info = nil
      end
    when 'Status::AbsenteeFormComplete'
      begin
        @info = @user.absentee_info
      rescue
        @find_location = true
        @info = nil
      end
    end
    @feeds = load_friend_feeds
    render :action => 'index'
  end
  
  def next_status
    @user.advance_status
    @user.save!
    redirect_to :action => @user.status_method
  end
  
#  # Takes the user back to the status they selected
#  # The status is passed in by its id.
#  def go_back
#    @user.status = Inflector.constantize(params[:status])
#    @user.save!
#    load_current_status_ivars
#    return if redirected?
#    render :json => { :id => @user.status::ID, :fbml_partial => render_to_string(:partial => @partial) }
#  end
  
  ######################## USER STATUS METHODS ###########################
  # Render the partials for each status.  It's expected that all calls to
  # these methods will be Ajax calls.
  ########################################################################
  def registration_not_started
    @info = @user.registration_info rescue nil
    render :json => {:find_location => true, :on_complete => 'registration_not_started'} and return if @info.nil?
    id = Status::RegistrationNotStarted::ID
    render :json => {:id => id, :fbml_partial => render_to_string(:partial => 'registration_not_started')}
  end
  
  def registration_form_complete
    id = Status::RegistrationFormComplete::ID
    render :json => {:id => id, :fbml_partial => render_to_string(:partial => 'registration_form_complete')}
  end
  
  def absentee_not_started
    @info = @user.absentee_info rescue nil
    render :json => {:find_location => true, :on_complete => 'absentee_not_started'} and return if @info.nil?
    id = Status::AbsenteeNotStarted::ID
    render :json => {:id => id, :fbml_partial => render_to_string(:partial => 'absentee_not_started')}
  end
  
  def absentee_form_complete
    @info = @user.absentee_info rescue nil
    render :json => {:find_location => true, :on_complete => 'absentee_form_complete'} and return if @info.nil?
    id = Status::AbsenteeFormComplete::ID
    render :json => {:id => id, :fbml_partial => render_to_string(:partial => 'absentee_form_complete')}
  end
  
  def absentee_confirmed
    id = Status::AbsenteeConfirmed::ID
    render :json => {:id => id, :fbml_partial => render_to_string(:partial => 'absentee_confirmed')}
  end
  
  def vote_pending
    id = Status::VotePending::ID
    render :json => {:id => id, :fbml_partial => render_to_string(:partial => 'vote_pending')}
  end
  
  def vote_complete
    id = Status::VoteComplete::ID
    render :json => {:id => id, :fbml_partial => render_to_string(:partial => 'vote_complete')}
  end

  private
  
  def load_friend_feeds
    @my_friends_with_app = User.find_all_by_fb_uid(facebook_params[:friends])
    if INCLUDE_MY_USER_IN_FEED
      @my_feeds_with_app << @user
    end
    @my_friends_with_app = @my_friends_with_app.inject({}) do |hash, user|
      hash[user.id] = user
      hash
    end
    if @my_friends_with_app.empty?
      @feeds = []
    else
      progressions_that_are_duplicated_in_achievements = [Status::VoteComplete::ID]
      @feeds = Progression.find(:all, :conditions => ['user_id IN (?) AND status_id NOT IN (?)', @my_friends_with_app.keys, progressions_that_are_duplicated_in_achievements], :order => 'created_at DESC', :limit => NUM_FEEDS)
      @feeds += Achievement.find(:all, :conditions => ['user_id IN (?)', @my_friends_with_app.keys], :order => 'created_at DESC', :limit => NUM_FEEDS)
      @feeds = @feeds.sort_by{|feed| feed.created_at}
      @feeds = @feeds[0...NUM_FEEDS]
    end
  end
  
  def ensure_walkthrough_complete
    if @user.status::ID <= Status::AddedApplication::ID
      redirect_to(:controller => 'walkthrough', :action => 'index')
      return false
    end
    true
  end

end
