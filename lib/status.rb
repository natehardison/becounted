# Module Status
#
# 
#
# Nate Hardison
# hardison@stanford.edu
# August 2008
module Status
  
  ############################### STATUS INFO #####################################
  #################################################################################
  # These need to be defined above the rest of the stuff so that the rest of the
  # module has access to these constants. TITLE is the title we'll use for all of
  # the voting partials; DESCRIPTION is the description we use on the stats pages.
  module Invited
    ID = 1
    TITLE = "Invited to the app"
    DESCRIPTION = "has been invited to BeCounted, but hasn't added it."
    ACCOMPLISHMENT = ""
  end
  
  module AddedApplication
    ID = 2
    TITLE = "Added the app"
    DESCRIPTION = "has added BeCounted, but hasn't yet figured out a voting state."
    ACCOMPLISHMENT = "joined BeCounted!"
  end
  
  module RegistrationNotStarted
    ID = 3
    TITLE = "Register to vote"
    SUBTITLE = ""
    HAS_DUE_DATE = true
    DESCRIPTION = "needs to fill out the voter registration form and mail it in."
    ACCOMPLISHMENT = "decided on a voting state and method."
  end
  
  module RegistrationFormComplete
    ID = 4
    TITLE = "Confirm your registration"
    SUBTITLE = "and eliminate any undesired surprises"
    HAS_DUE_DATE = false
    DESCRIPTION = "is waiting to confirm voter registration."
    ACCOMPLISHMENT = "registered to vote!"
  end
  
  module AbsenteeNotStarted
    ID = 5
    TITLE = "Get an absentee ballot"
    SUBTITLE = "to facilitate voting in your underwear"
    HAS_DUE_DATE = true
    DESCRIPTION = "needs to fill out absentee ballot request form and mail it in."
    ACCOMPLISHMENT = "confirmed registration status."
  end
  
  module AbsenteeFormComplete
    ID = 6
    TITLE = "Confirm absentee status"
    SUBTITLE = "since they don't send the ballots just any time."
    HAS_DUE_DATE = false
    DESCRIPTION = "is waiting to confirm absentee voter status."
    ACCOMPLISHMENT = "sent in the absentee request form."
  end
  
  module AbsenteeConfirmed
    ID = 7
    TITLE = "Report getting your ballot"
    SUBTITLE = "just making sure that you're ready to go!"
    HAS_DUE_DATE = false
    DESCRIPTION = "is waiting to receive absentee ballot."
    ACCOMPLISHMENT = "confirmed absentee status."
  end
  
  module VotePending
    ID = 8
    TITLE = "Vote!"
    SUBTITLE = "and make a difference!"
    HAS_DUE_DATE = true
    DESCRIPTION = "needs to go vote!"
    ACCOMPLISHMENT = "is ready to vote!"
  end
  
  module VoteComplete
    ID = 9
    TITLE = "Congratulations!"
    SUBTITLE = "pure awesomeness!"
    HAS_DUE_DATE = false
    DESCRIPTION = "has voted!"
    ACCOMPLISHMENT = "has voted!"
  end
  
  ############################ STATUS CLASS METHODS ################################
  ################################################################################## 
  
  # Make sure this gets defined before other constants, since it relies on the modules
  # being the only constants defined at this point.
  STATUSES = self.constants.inject({}) do |hash, status| 
    status = Inflector.constantize("Status::#{status}")
    hash[status::ID] = status
    hash
  end
  
  def self.accomplishment_for(status_id)
    STATUSES[status_id]::ACCOMPLISHMENT
  end
  
  # Returns an array of all of the statuses involved in voting absentee.  This is
  # used when figuring out which partials to render in the voting page.  Don't use
  # this method directly--use "@user.get_voting_statuses" instead which returns an
  # id and a title for each status.
  def self.voting_absentee_statuses
    STATUSES.sort.inject([]) do |array, status|
      array << status.last if status.first > AddedApplication::ID
      array
    end
  end
  
  # Returns an array of all of the statuses involved in voting in person at the polls.
  # See above comment.
  def self.voting_in_person_statuses
    self.voting_absentee_statuses.reject { |status| status.name =~ /Absentee/ }
  end
  
  ########################### STATUS INSTANCE METHODS ##############################
  ##################################################################################
  # These are all being included by the user, so we have access to all of the user's
  # fields and ivars.
  #
  # Relevant user fields: @current_status (string), @id (Fixnum), @progressions (object)
  # Relevant user methods: voting_absentee?
  
  # Advances the user's status to the next applicable one, depending on whether or not
  # the user needs to register to vote absentee.
  def advance_status
    self.status = next_status
  end
  
  # Pulls the appropriate statuses for the user.  This is used on the vote index page
  # when we need to know which partials to show to the user.
  def get_voting_statuses
    if voting_in_person?
      statuses = Status.voting_in_person_statuses
    else
      statuses = Status.voting_absentee_statuses
    end
    
    # Time for special cases!!
    case self.voting_state.name
    when "North Dakota" # ND doesn't have voter registration
      statuses = statuses.reject { |status| status.name =~ /Registration/ }
    when "Oregon" # OR always votes absentee, no need to show it
      statuses = statuses.reject { |status| status.name =~ /Absentee/ }
    end
    statuses
  end

  def next_status
      (skipping_absentee_registration? ? VotePending : STATUSES[self.status::ID + 1]) || self.status
  end
  
  # Pulls the next status object out of the STATUSES array. Won't do anything if you try
  # to advance past the end of the STATUSES array (just returns the current status)
  def next_status
    (skipping_absentee_registration? ? VotePending : STATUSES[self.status::ID + 1]) || self.status
  end
  
  # Returns the ratio as an array like [numerator, denominator] of how far along the 
  # user is in the voting process.
  def progress_ratio
    return [0, 7] if self.status_id < RegistrationNotStarted::ID
    voting_absentee? ? statuses = Status.voting_absentee_statuses : statuses = Status.voting_in_person_statuses
    progress = statuses.index(self.status) + 1 # otherwise they start at 0
    total = statuses.length
    [progress, total]
  end
  
  # sort on this to get users sorted by progress from incomplete to complete
  def progress_sorted_index
    [[0,7], [1,7], [1,4], [2,7], [2,4], [3,7], [4,7], [5,7], [3,4], [6,7], [4,4], [7,7]].index(progress_ratio)
  end
  
  # Pulls the name of the user's current status.  We've made the usual current_status
  # method private just so that the client always gets the user's status like this (in
  # case implementation gets changed). This is really only needed for the vote and
  # absentee controllers, since they need to load a certain partial based on the status
  # of the user.
  def status
    STATUSES[self.status_id]
  end
  
  # Sets the user's current status.  Expects a status id (a string) to be passed in.
  # Also does some checking to see if we're going back or skipping past any statuses.
  # DOES SAVE!
  def status=(new_status)
    return if self.status == new_status
    if going_back_to?(new_status)
      revert_to(new_status)
    else
       if jumping_to?(new_status) #if we're skipping one or more statuses
         # fill_in_achievements here
       end
       # add a progression to the user
       if new_status::ID > AddedApplication::ID
        self.progressions << Progression.create(:user => self, :status_id => new_status::ID)
       end
    end
    # now set the status--NEED to reference self.status_id here (.status = infinite loop)
    self.status_id = new_status::ID
    self.check_for_new_achievements
    self.save!
  end
  
  # Returns the nicely formatted description of the user's current status.
  def status_description
    self.status::DESCRIPTION
  end
  
  def status_method
    Inflector.underscore(self.status.name.sub("Status::", ""))
  end
  
  ########################### PRIVATE HELPER METHODS ###############################
  ##################################################################################
  private
  
  # Returns true if a user is moving back to a previous status
  def going_back_to?(new_status)
    !self.status_id.nil? && (new_status::ID <  self.status::ID)
  end
  
  # Returns true if a user is jumping forward more than one status.  This is intended
  # to be a way to record progressions for the user
  def jumping_to?(new_status)
    !self.status_id.nil? && (new_status::ID > (self.status::ID + 1))
  end
  
  # Pulls the next status object out of the STATUSES array. Won't do anything if you try
  # to advance past the end of the STATUSES array (just returns the current status)
  #def next_status
   # (skipping_absentee_registration? ? VotePending : STATUSES[self.status::ID + 1]) || self.status
 # end
  
  # Reverts our user to the given status.  
  def revert_to(status)
    if status == AbsenteeNotStarted
      self.county = nil
      self.town = nil
      self.zip_code = nil
    end
  end
  
  def set_initial_status
    self.status = Invited
  end
  
  # Returns true if the user doesn't have to vote absentee and we're at the point where we
  # need to skip over the absentee statuses.
  def skipping_absentee_registration?
    (!voting_absentee? and self.status == RegistrationFormComplete) || 
      (self.status == RegistrationFormComplete and self.voting_state.name == "Oregon")
  end
  
end