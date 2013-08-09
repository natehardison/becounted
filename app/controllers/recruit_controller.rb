class RecruitController < ApplicationController
  
  #TODO: figure out how many invites the user has left
  def index
    # This line might have to be changed if we move to preload FQL
    @exclude_ids = User.find_all_by_fb_uid(facebook_params[:friends]).map {|x| x.fb_uid}.join(',')
    if params[:competitive]
      n_good_states = 10
      good_states = State.find(:all, :select => 'code,name', :conditions => ['competitive <= ?', n_good_states])
      good_state_names = good_states.map{|x| x.code.downcase} + good_states.map{|x| x.name.downcase}
      query = "SELECT uid, hometown_location.state FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=#{@user.fb_uid})"
      friends_without_app = Facebook::API::Admin::FQL.query(query, @user.session_key)
      friends_without_app_from_lousy_states = friends_without_app.reject{|x| good_state_names.include?((x['hometown_location'] || '').downcase)}
      @exclude_ids += friends_without_app_from_lousy_states.map{|x| x['uid']}.join(',')
    end
    render :action => 'index'
  end
  
  # TODO: Make this show a "thanks for inviting your friends" thing
  def post_invite
    @invited_ids = params[:ids]
    if @invited_ids.blank?
      redirect_to :controller => :home, :action => :index and return
    end
    @invited_ids.each() do |invited_facebook_uid|
      invited_user = User.find_or_create_by_fb_uid(invited_facebook_uid)
      Invitation.find_or_create_by_invitor_id_and_invitee_id(@user.id, invited_user.id)
    end
    flash[:notice] = "Thanks for recruiting your friends!"
    redirect_to :action => 'index'
  end

end
