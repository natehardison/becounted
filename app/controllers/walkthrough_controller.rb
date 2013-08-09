class WalkthroughController < ApplicationController
  skip_filter :import_user, :only => [:ajax_college_list, :ajax_dorm_list]
  skip_filter :add_achievements_to_minifeed, :only => [:ajax_college_list, :ajax_dorm_list]
  
  def index
    if @user.voting_method.nil?
      redirect_to :action => 'select_home_state_and_college'
    else
      redirect_to :action => 'select_voting_method'
    end
  end
  
  def select_home_state_and_college
    # Get all of the states into a hash to easily find them w/out db query later
    @states = Hash[ *State.find(:all).collect{ |state| [state.name, state.id] }.flatten ]
    # TODO: is there a way to merge their user with our user?
    
    # Now get user's state and college for autofill
    query = "SELECT hometown_location.state, education_history.name FROM user WHERE uid=#{@user.fb_uid}"
    user_info = Facebook::API::Admin::FQL.query(query, @user.session_key).first
    home_state = user_info['hometown_location']['state']
    @user_state = @states[home_state]
    
    @colleges, @user_college = get_college_info(user_info['education_history'])
    @dorms = Dorm.find(:all, :conditions => {:college_id => @user_college}, :order => 'name ASC').map{|x| [x.name, x.id]}
    
    render :action => 'select_home_state_and_college'
  end
  
  # This should be transformed at some point into a typeahead
  # Ajax responder.
  def ajax_college_list
    render :json => { :colleges => College.find(:all, :order => 'name ASC').map{|x| [x.name, x.id]} }
  end
  
  # Renders all the dorms for the given college.
  def ajax_dorm_list
    begin
      college = College.find(params[:college_id])
      dorms = college.dorms.find(:all, :order => 'name ASC').map{|x| [x.name, x.id]}
    rescue ActiveRecord::RecordNotFound
      dorms = [];
    end
    render :json => { :dorms => dorms }
  end
  
  # Prompts the user to select where and how they would like to vote
  # Recommends voting in the more competitive state and displays the 
  # requirements for voting in both states.
  def select_voting_method
    begin
      @home_state = State.find(params[:home_state])
    rescue ActiveRecord::RecordNotFound
      #redirect_to :controller => 'home', :action => 'error'
    end
  
    @home_abs_hurdles = @home_state.absentee_hurdles#.map{ |x| x.req }
    @home_voting_reqs = @home_state.voting_reqs.map { |x| x.req }
  
    # User must have no college
    if params[:college].blank?
      @home_abs_hurdles = @home_state.absentee_hurdles
      @register_state_id = @home_state.id unless params[:register_status] == "not_registered"
      render :action => 'select_voting_method_same_state' and return
    end
    
    begin
      @college = College.find(params[:college])
    rescue ActiveRecord::RecordNotFound => e
      #redirect_to :controller => 'home', :action => 'error'
    end
    
    @dorm = Dorm.find_by_id(params[:dorm]) # we don't care if it's null
    
    @college_state = @college.state 
    
    if params[:register_status] == "not_registered"
      @register_state_id = nil
    elsif params[:register_status] == params[:home_state]
      @register_state_id = @home_state.id
    elsif params[:register_status] == params[:college]
      @register_state_id = @college_state.id
    end
    
    render :action => 'select_voting_method_same_state' and return if @home_state == @college_state
    
    @college_abs_hurdles = @college_state.absentee_hurdles#.map{ |x| x.req }
    @college_ranking = Inflector.ordinalize(@college_state.competitive)
    @home_ranking = Inflector.ordinalize(@home_state.competitive)
    @college_voting_reqs = @college_state.voting_reqs.map { |x| x.req }
    render :action => 'select_voting_method_diff_states'
  end
  
  def set_voting_method
    begin
      home_state = State.find(params[:home_state_id])
      voting_method = Inflector.constantize("VotingMethod::#{params[:voting_method]}")
      voting_state = State.find(params[:voting_state_id])
    rescue
      #redirect_to :controller => :home, :action => :error, :message => 'Bad voting state or method!' and return
    end
    
    @user.college = College.find_by_id(params[:college_id])
    @user.dorm = Dorm.find_by_id(params[:dorm_id])
    @user.home_state = home_state
    @user.voting_method = voting_method
    @user.voting_state = voting_state
    
    if voting_state.code == "ND"
      @user.status = Status::AbsenteeNotStarted
    else
      @user.status = Status::RegistrationNotStarted #status= saves the user
    end
    
    unless params[:re_register]
      if params[:voting_state_id] == params[:register_state_id]
        if @user.voting_absentee?  && voting_state.code != "OR"
          @user.status = Status::AbsenteeNotStarted
        else
          @user.status = Status::VotePending
        end
      end
    end
    
    redirect_to :controller => 'home', :action => 'index'
  end
  
  private
  
  # Attempts to translate Facebook's college names and our own
  # database's college names by doing a regular expression search.
  # We split the FB college name into tokens by capital letters and
  # search for matches in that order.
  def get_college_info(education_history)
    return [nil, nil] if education_history.empty?
    sql_regexp = education_history.inject([]) do |array, college|
      name = college['name']
      matches = name.scan(/[A-Z][^A-Z]*/x).map{|match| match.strip}
      array << "[[:<:]]" + matches.join(".*[[:<:]]") + ".*" unless matches.empty?
      array
    end
    colleges = College.find(:all, :conditions => ["name REGEXP ?", sql_regexp.join("|")], :order => "name ASC")
    colleges_hash = colleges.inject({}){|hash, college| hash[college.name] = college.id; hash}
    ruby_regexp = sql_regexp[0].gsub("[[:<:]]", '\b') #translate into a ruby regexp
    current_college = colleges_hash[colleges_hash.keys.grep(/#{ruby_regexp}/)[0]] # Assume it's the first one
    [colleges_hash, current_college]
  end
end