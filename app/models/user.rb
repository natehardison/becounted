class User < ActiveRecord::Base
  include Status
  include VotingMethod
  
  acts_as_facebook_user
  
  belongs_to :college
  belongs_to :dorm
  belongs_to :county
  belongs_to :home_state, :class_name => 'State', :foreign_key => 'home_state_id'
  belongs_to :town
  belongs_to :voting_state, :class_name => 'State', :foreign_key => 'voting_state_id'
  belongs_to :zip_code
  
  has_many :achievements
  has_many :active_dates
  has_many :progressions
  
  validates_uniqueness_of :fb_uid
  
  after_create :set_initial_status

  def absentee_info
    state = self.voting_state

    # we'll pull address/phone info first
    if state.code == 'MA'
      info = { :ma_sucks => true }
    elsif !self.town.nil? && WEIRD_STATES.include?(state.code) && WEIRD_TOWNS.include?(self.town.name)
      info = { :phone => self.town.phone, 
               :address => self.town.address, 
               :place_name => "#{self.town.name}, #{state.code}" }
    elsif state.votes_by_town?
      info = { :phone => self.town.phone, 
               :address => self.town.address, 
               :place_name => "#{self.town.name}, #{state.code}" }
    else
      info = { :phone => self.county.phone, 
               :address => self.county.address,
               :place_name => "#{self.county.name}, #{state.code}" }
    end
    
    # now we get the absentee form
    state.code =~ /ME|MN/ ? extension = ".doc" : extension = ".pdf"
    form_path = ABSENTEE_FORM_PATH + state.code.downcase + extension
    if state.name == "Delaware"
      suffix = "_#{self.county.name.sub(' ', '_').downcase}"
      form_path.insert(form_path.rindex(extension), suffix)
    end  
    form_file = File.join(RAILS_ROOT, "public", form_path)
    form = BASE_URL + form_path if File.exists?(form_file)
    info.merge({:deadline => state.abs_request_deadline, :form => form})
  end
  
  def registration_info
    voting_state = self.voting_state
    case voting_state.code
    when "NH"
      { :deadline => voting_state.reg_deadline,
        :form => :new_hampshire,
        :phone => self.town.phone, 
        :address => self.town.address }
    when "WY"
      { :deadline => voting_state.reg_deadline, 
        :phone => self.county.phone, 
        :address => self.county.address, 
        :form => :wyoming, 
        :form_link => BASE_URL + ABSENTEE_FORM_PATH + "wy_reg.pdf" }
    else
      { :deadline => voting_state.reg_deadline,
        :address => voting_state.address, 
        :form => :rock_the_vote }
    end
  end
  
  alias get_college college
  def college
    return College.new(:name => "None") if self.college_id.nil?
    self.get_college
  end
  
  alias get_dorm dorm
  def dorm
    return Dorm.new(:name => "None") if self.dorm_id.nil?
    self.get_dorm
  end
  
  # nil
  def next_end_deadline
    #if self.status_id <
    return Date.new(2008, 10, 24) 
  end
  
  # nil if no deadline
  def next_start_deadline
    #TODO: write me
    return Date.new(2008, 10, 1)  
  end
  
  # TODO: save here?
  def start_over
    self.status = AddedApplication
    self.college = nil
    self.county = nil
    self.home_state = nil
    self.town = nil
    self.voting_method_id = nil
    self.voting_state = nil
    self.zip_code = nil
  end
  
  # does not save user
  def update_score
    n_successful_invitations = Invitation.count(:conditions => {:accepted => true, :invitor_id => self.id})
    self.points = 0
    self.points += 5 * n_successful_invitations
    self.achievements.each() do |achievement|
      self.points += achievement.action::POINTS
    end
  end
  
  def check_for_new_achievements
    
    # User selected a voting method
    if (self.status_id >= RegistrationNotStarted::ID && self.status_id <= VotePending::ID) && !self.voting_method.nil?
      RAILS_DEFAULT_LOGGER.error('we got here!!! ***')
      if self.voting_absentee? 
        # remove achievements for in_person because of possible "go back"
        Achievement.delete_all(['user_id = ? AND action_id = ?', self.id, AchievementAction::ChoseVoteInPerson::ID])
        User.create_achievement_for_user_if_not_exist(AchievementAction::ChoseVoteAbsentee, self)
      elsif self.voting_in_person?
        # remove achievements for absentee because of possible "go back"
        Achievement.delete_all(['user_id = ? AND action_id = ?', self.id, AchievementAction::ChoseVoteAbsentee::ID])
        User.create_achievement_for_user_if_not_exist(AchievementAction::ChoseVoteInPerson, self)
      end
    end
    
    # User just added the application
    if self.status == AddedApplication
      # if I was invited, set my invitation to accepted
      Invitation.find_all_by_invitee_id(self.id).each() do |invitation|
        invitation.accepted = true
        invitation.save!
        
        n_users_recruited_by_invitor = Invitation.count(:conditions => ['invitor_id = ? AND accepted = ?', invitation.invitor_id, true])
        if n_users_recruited_by_invitor >= 25
          User.create_achievement_for_user_if_not_exist(AchievementAction::Recruit25, invitation.invitor)
        end
        if n_users_recruited_by_invitor >= 100
          User.create_achievement_for_user_if_not_exist(AchievementAction::Recruit100, invitation.invitor)
        end
        if n_users_recruited_by_invitor >= 250
          User.create_achievement_for_user_if_not_exist(AchievementAction::Recruit250, invitation.invitor)
        end
        if n_users_recruited_by_invitor >= 500
          User.create_achievement_for_user_if_not_exist(AchievementAction::Recruit500, invitation.invitor)
        end
        if n_users_recruited_by_invitor >= 2000
          User.create_achievement_for_user_if_not_exist(AchievementAction::Recruit2000, invitation.invitor)
        end
        
        if !self.dorm_id.nil? && !['Other', 'Off Campus'].include?(self.dorm.name)
          if self.dorm_id == invitation.invitor.dorm_id
            n_users_recruited_by_invitor_in_dorm = Invitation.count(:conditions => ['invitor_id = ? AND accepted = ?', invitation.invitor_id, true])
            if n_users_recruited_by_invitor_in_dorm >= 10
              User.create_achievement_for_user_if_not_exist(AchievementAction::Recruit10FromDorm, invitation.invitor)
            end
          end
          
          n_users_in_my_dorm = User.count(:conditions => ['dorm_id = ?', self.dorm_id])
          if n_users_in_my_dorm >= 10
            User.find(:select => 'id', :conditions => ['dorm_id = ?', self.dorm_id]).each() do |user_in_dorm|
              User.create_achievement_for_user_if_not_exist(AchievementAction::PartOfDormWith10ResidentsJoined, user_in_dorm)
            end
          end
        end
        
        
        
        invitation.invitor.update_score
        invitation.invitor.save!
      end
      
      n_users = User.count()
      if n_users <= 5000
        User.create_achievement_for_user_if_not_exist(AchievementAction::OneOfFirst5000ToJoin, self)
      end
    end
    
    # User has a college and state now
    if self.status == RegistrationNotStarted
      n_users_in_my_college = User.count(:conditions => ['college_id = ?', self.college_id])
      
      if n_users_in_my_college <= 50
        User.create_achievement_for_user_if_not_exist(AchievementAction::OneOfFirst50ToJoinAtSchool, self)
      elsif n_users_in_my_college <= 500
        User.create_achievement_for_user_if_not_exist(AchievementAction::OneOfFirst500ToJoinAtSchool, self)
      end
    end
    
    # User just voted
    if self.status == VoteComplete
      User.create_achievement_for_user_if_not_exist(AchievementAction::Voted, self)
    end
    
    # User received absentee ballot
    if self.status == VotePending && self.voting_absentee?
      User.create_achievement_for_user_if_not_exist(AchievementAction::ReceivedAbsenteeBallot, self)
    end
    
    self.update_score()
  end
  
  private
  
  # only requires the user.id to be filled out
  def self.create_achievement_for_user_if_not_exist(action, user)
    if Achievement.find(:first, :select => '1', :conditions => ['user_id = ? AND action_id = ?', user.id, action::ID]).nil?
      Achievement.create(:action_id => action::ID, :user_id => user.id, :added_to_minifeed => false)
    end
  end
  
end