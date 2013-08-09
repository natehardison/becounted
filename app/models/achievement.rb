class Achievement < ActiveRecord::Base
  include AchievementAction
  
  #has_many :achievements_users
  belongs_to :user
  
  def feed_data
    data = {}
    data['achievement_action'] = action.minifeed_suffix(self.user)
    data['comment'] = 'cool!'
    data['images'] = [{"src"=>"http://fjqqqyaa.joyent.us/images/logo.jpg","href"=>"http://apps.facebook.com/becounted"}]
    return data
  end
  
end
