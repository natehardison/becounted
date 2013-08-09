module AchievementAction
  
  class ChoseVoteAbsentee
    ID = 1
    ICON = ""
    POINTS = 0
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      'just chose to vote absentee'
    end
  end
  
  class ChoseVoteInPerson
    ID = 2
    ICON = ""
    POINTS = 0
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      'just chose to vote in person'
    end
  end
  
  class Voted
    ID = 3
    ICON = ""
    POINTS = 0
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      'just voted'
    end
  end
  
  class ReceivedAbsenteeBallot
    ID = 4
    ICON = ""
    POINTS = 5
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      'just received an absentee ballot'
    end
  end
  
  class OneOfFirst50ToJoinAtSchool
    ID = 7
    ICON = ""
    POINTS = 5
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      suffix = "was one of the first 50 to join BeCounted"
      college = user.college.name rescue nil
      suffix += " at #{college}" unless college.blank?
    end
  end
  
  class OneOfFirst500ToJoinAtSchool
    ID = 8
    ICON = ""
    POINTS = 5
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      suffix = "was one of the first 500 to join BeCounted"
      college = user.college.name rescue nil
      suffix += " at #{college}" unless college.blank?
    end
  end
  
  class OneOfFirst5000ToJoin
    ID = 9
    ICON = ""
    POINTS = 0
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      "was one of the first 5000 to join BeCounted"
    end
  end
  
  class Recruit10FromDorm
    ID = 10
    ICON = ""
    POINTS = 5
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      "just recruited 10 people to vote"
    end
  end
  
  class Recruit25
    ID = 11
    ICON = ""
    POINTS = 5
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      "just recruited 25 people to vote"
    end
  end
  
  class Recruit100
    ID = 12
    ICON = ""
    POINTS = 5
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      "just recruited 100 people to vote"
    end
  end
  
  class Recruit250
    ID = 13
    ICON = ""
    POINTS = 10
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      "just recruited 250 people to vote"
    end
  end
  
  class Recruit500
    ID = 14
    ICON = ""
    POINTS = 20
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      "just recruited 500 people to vote"
    end
  end
  
  class Recruit2000
    ID = 15
    ICON = ""
    POINTS = 0
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      "just recruited 2000 people to vote"
    end
  end
  
  class PartOfDormWith10ResidentsJoined
    ID = 17
    ICON = ""
    POINTS = 5
    DESCRIPTION = ""
    def self.minifeed_suffix(user)
      "is in a dorm with at least 10 people voting"
    end
  end
  
  ############################ ACHIEVEMENT CLASS METHODS ################################
  #######################################################################################
  
  # Make sure this gets defined before other constants, since it relies on the modules
  # being the only constants defined at this point.
  ACTIONS = self.constants.inject({}) do |hash, action| 
    action = Inflector.constantize("AchievementAction::#{action}")
    hash[action::ID] = action
    hash
  end
  
  ########################### ACTION INSTANCE METHODS ##############################
  ##################################################################################
  # These are all being included by the user, so we have access to all of the user's
  # fields and ivars.
  
  def action
    ACTIONS[self.action_id]
  end
    
end
