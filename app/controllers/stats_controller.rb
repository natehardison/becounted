class StatsController < ApplicationController
  
  def index
    @aggregate_stats = get_stats('1=1', [])
    render :action => 'index'
  end
  
  def college_states
    states = State.find(:all, :order => 'name')
    @breakdown_stats = states.map() do |state|
      stat = {:name => state.name, :link => url_for(:action => 'college_state', :id => state.id)}
      stat.merge!(get_stats("colleges.state_id = #{state.id}", [:college]))
      stat
    end
    render :action => 'college_states'
  end
  
  def voter_states
    states = State.find(:all, :order => 'name')
    @breakdown_stats = states.map() do |state|
      stat = {:name => state.name, :link => url_for(:action => 'voter_state', :id => state.id)}
      stat.merge!(get_stats("voting_state_id = #{state.id}", []))
      stat
    end
    render :action => 'voter_states'
  end
  
  def college_state
    @state = State.find(params[:id])
    colleges = @state.colleges.find(:all, :order => 'name')
    @aggregate_stats = get_stats("colleges.state_id = #{@state.id}", [:college])
    @breakdown_stats = colleges.map() do |college|
      stat = {:name => college.name, :link => url_for(:action => 'college', :id => college.id)}
      stat.merge!(get_stats("college_id = #{college.id}", []))
      stat
    end
    render :action => 'college_state'
  end
  
  # What to do here?
  def voter_state
    @state = State.find(params[:id])
    colleges = College.find(:all, :conditions => ["states.id = #{@state.id}"], :joins => {:students => :voting_state}, :order => 'name')
    @aggregate_stats = get_stats("colleges.state_id = #{@state.id}", [:college])
    @breakdown_stats = colleges.map() do |college|
      stat = {:name => college.name}
      stat.merge!(get_stats("college_id = #{college.id}", []))
      stat
    end
    render :action => 'voter_state'
  end
  
  def college
    @college = College.find(params[:id])
    @aggregate_stats = get_stats("college_id = #{@college.id}", [])
    dorms = @college.dorms
    @breakdown_stats = dorms.map() do |dorm|
      stat = {:name => dorm.name}
      stat.merge!(get_stats("dorm_id = #{dorm.id}", []))
      stat
    end
    render :action => 'college'
  end
  
  protected
  
  # min_days and max_days are inclusive
  DEADLINE_BUCKETS = [
    {:code => :ahead, :name => 'Ahead', :min_days => 20, :max_days => 999999},
    {:code => :on_track, :name => 'On Track', :min_days => 8, :max_days => 19},
    {:code => :at_risk, :name => 'At Risk', :min_days => 0, :max_days => 7},
    {:code => :missed_deadline, :name => 'Missed Deadline', :min_days => -999999, :max_days => -1},
  ]
  
  VOTE_DAY_SQL_STRING = "'2008-11-04'"
  
  def get_stats(condition, includes)
    result = {:total => {}, :absentee => {}, :in_person => {}}
    
    # users
    result[:total][:users] = User.count(:conditions => "(#{condition})", :include => includes)
    result[:absentee][:users] = User.count(:conditions => "(#{condition}) AND voting_method_id = \"#{VotingMethod::Absentee::ID}\"", :include => includes)
    result[:in_person][:users] = User.count(:conditions => "(#{condition}) AND voting_method_id = \"#{VotingMethod::InPerson::ID}\"", :include => includes)
    
    # ahead, on_track, at_risk, missed_deadline
    DEADLINE_BUCKETS.each() do |bucket|

      # include these?
      #status_possibilities << "status_id = #{Status::Invited::ID}"
      #status_possibilities << "status_id = #{Status::AddedApplication::ID}"
      
      # absentee
      status_possibilities = []
      status_possibilities << "status_id = #{Status::RegistrationNotStarted::ID} AND DATEDIFF(states.reg_deadline, NOW()) BETWEEN #{bucket[:min_days]} AND #{bucket[:max_days]}"
      status_possibilities << "status_id = #{Status::RegistrationFormComplete::ID} AND DATEDIFF(states.abs_request_deadline, NOW()) BETWEEN #{bucket[:min_days]} AND #{bucket[:max_days]}"
      status_possibilities << "status_id = #{Status::AbsenteeNotStarted::ID} AND DATEDIFF(states.abs_request_deadline, NOW()) BETWEEN #{bucket[:min_days]} AND #{bucket[:max_days]}"
      status_possibilities << "status_id = #{Status::AbsenteeFormComplete::ID} AND DATEDIFF(states.abs_closing_deadline, NOW()) BETWEEN #{bucket[:min_days]} AND #{bucket[:max_days]}"
      status_possibilities << "status_id = #{Status::AbsenteeConfirmed::ID} AND DATEDIFF(#{VOTE_DAY_SQL_STRING}, NOW()) BETWEEN #{bucket[:min_days]} AND #{bucket[:max_days]}"
      if bucket[:code] == :ahead
        status_possibilities << "status_id = #{Status::VotePending::ID}"
        status_possibilities << "status_id = #{Status::VoteComplete::ID}"
      end
      status_possibilities_sql = status_possibilities.map{|x| "(#{x})"}.join(' OR ')
      result[:absentee][bucket[:code]] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::Absentee::ID}\" AND (#{status_possibilities_sql})"], :include => [:voting_state] + includes)

      # in_person
      status_possibilities = []
      status_possibilities << "status_id = #{Status::RegistrationNotStarted::ID} AND DATEDIFF(states.reg_deadline, NOW()) BETWEEN #{bucket[:min_days]} AND #{bucket[:max_days]}"
      status_possibilities << "status_id = #{Status::RegistrationFormComplete::ID} AND DATEDIFF(#{VOTE_DAY_SQL_STRING}, NOW()) BETWEEN #{bucket[:min_days]} AND #{bucket[:max_days]}"
      if bucket[:code] == :ahead
        status_possibilities << "status_id = #{Status::VotePending::ID}"
        status_possibilities << "status_id = #{Status::VoteComplete::ID}"
      end
      status_possibilities_sql = status_possibilities.map{|x| "(#{x})"}.join(' OR ')
      result[:in_person][bucket[:code]] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::InPerson::ID}\" AND (#{status_possibilities_sql})"], :include => [:voting_state] + includes)

      # total
      result[:total][bucket[:code]] = result[:absentee][bucket[:code]] + result[:in_person][bucket[:code]]
      
    end
    
    result[:absentee][:not_started] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::Absentee::ID}\" AND status_id = #{Status::RegistrationNotStarted::ID}"], :include => [:voting_state] + includes)
    result[:absentee][:registered] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::Absentee::ID}\" AND status_id IN (#{Status::RegistrationFormComplete::ID},#{Status::AbsenteeNotStarted::ID})"], :include => [:voting_state] + includes)
    result[:absentee][:confirmed_registration] = 0 #TODO make this work
    result[:absentee][:requested_absentee] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::Absentee::ID}\" AND status_id = #{Status::AbsenteeFormComplete::ID}"], :include => [:voting_state] + includes)
    result[:absentee][:confirmed_absentee] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::Absentee::ID}\" AND status_id = #{Status::AbsenteeConfirmed::ID}"], :include => [:voting_state] + includes)
    result[:absentee][:voted] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::Absentee::ID}\" AND status_id IN (#{Status::VotePending::ID},#{Status::VoteComplete::ID})"], :include => [:voting_state] + includes)

    result[:in_person][:not_started] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::InPerson::ID}\" AND status_id = #{Status::RegistrationNotStarted::ID}"], :include => [:voting_state] + includes)
    result[:in_person][:registered] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::InPerson::ID}\" AND status_id IN (#{Status::RegistrationFormComplete::ID},#{Status::AbsenteeNotStarted::ID})"], :include => [:voting_state] + includes)
    result[:in_person][:confirmed_registration] = 0 #TODO make this work
    result[:in_person][:requested_absentee] = 0
    result[:in_person][:confirmed_absentee] = 0
    result[:in_person][:voted] = User.count(:conditions => ["(#{condition}) AND voting_method_id = \"#{VotingMethod::InPerson::ID}\" AND status_id IN (#{Status::VotePending::ID},#{Status::VoteComplete::ID})"], :include => [:voting_state] + includes)

    [:not_started, :registered, :confirmed_registration, :requested_absentee, :confirmed_absentee, :voted].each() do |col|
      result[:total][col] = result[:absentee][col] + result[:in_person][col]
    end
    
    result
  end
  
  def set_selected_main_link
    @main_link = 'friends'
  end
  
end
