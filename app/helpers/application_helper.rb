# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def num_days_left_to_complete(status)
    if status == Status::RegistrationNotStarted
      "#{num_days_until(@voting_state.reg_deadline)} DAYS LEFT"
    elsif status == Status::AbsenteeNotStarted
      "#{num_days_until(@voting_state.abs_request_deadline)} DAYS LEFT"
    elsif status == Status::AbsenteeFormComplete
      "#{num_days_until(@voting_state.abs_closing_deadline)} DAYS LEFT"
    elsif status == Status::VotePending
      "#{num_days_until_election} DAYS LEFT"
    end
  end
  
  def num_days_until(date)
    (date - Date.today).to_i  
  end

  def num_days_until_election
    num_days_until(ELECTION_DAY)
  end
  
  def list_hurdles(array)
    "<p>#{array.map{|x| x.to_html }.join('')}</p>"
  end
  
  def to_ul(array)
    "<ul>#{array.map { |x| '<li>' + x.to_s + '</li>' }.join('')}</ul>"
  end
  
end
