module WalkthroughHelper
  def more_competitive
    return @home_state if @home_state.is_more_competitive_than?(@college_state)
    return @college_state
  end
  
  def less_competitive
    return @home_state if @college_state.is_more_competitive_than?(@home_state)
    return @college_state
  end
  
  def more_competitive?(state)
    if state == @home_state
      return @home_state.is_more_competitive_than?(@college_state)
    else
      return @college_state.is_more_competitive_than?(@home_state)
    end
  end
end
