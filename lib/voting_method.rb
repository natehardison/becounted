module VotingMethod
  
  module InPerson
    ID = 1
    TITLE = "in person, at the polls"
  end
  
  module Absentee
    ID = 2
    TITLE = "by absentee ballot"
  end
  
  ######################### VOTING METHOD CLASS METHODS ############################
  ################################################################################## 
  
  # Make sure this gets defined before other constants, since it relies on the modules
  # being the only constants defined at this point.
  VOTING_METHODS = self.constants.inject({}) do |hash, method| 
    method = Inflector.constantize("VotingMethod::#{method}")
    hash[method::ID] = method
    hash
  end
  
  ########################### STATUS INSTANCE METHODS ##############################
  ##################################################################################
  # These are all being included by the user, so we have access to all of the user's
  # fields and ivars.
  
  def voting_method
    VOTING_METHODS[self.voting_method_id]
  end
  
  def voting_method=(method)
    self.voting_method_id = method::ID
  end
  
  def voting_absentee?
    !self.voting_method.nil? && self.voting_method == Absentee
  end
  
  def voting_in_person?
    !self.voting_method.nil? && self.voting_method == InPerson
  end
  
end