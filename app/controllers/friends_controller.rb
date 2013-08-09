class FriendsController < ApplicationController
  
  def index
    render :action => 'sorry'
  end
  
  def index
    
    render :action => 'index'
  end
  
  def show
    if params[:id].blank?
      @my_friends_with_app = User.find(:all, :conditions => ['fb_uid in (?) AND privacy_enabled = ?', facebook_params[:friends], false])
      @my_friends_with_app = @my_friends_with_app.sort_by{|friend| @friends_with_app.find{|x| x.uid == friend.fb_uid}.name}
      query = "SELECT flid, name FROM friendlist WHERE owner=#{@user.fb_uid}"
      @friend_lists = Facebook::API::Admin::FQL.query(query, @user.session_key)
    else
      query = "SELECT uid FROM friendlist_member WHERE flid=#{params[:id]}"
      @current_list = Facebook::API::Admin::FQL.query(query, @user.session_key)
    end
  end

end
