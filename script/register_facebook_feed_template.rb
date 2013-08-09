one_line_story_templates = [
  '{*actor*} {*achievement_action*}',
  '{*actor*} used <a href="http://apps.facebook.com/becounted">BeCounted</a> to make their vote count'
]
short_story_templates = [ 
  { 
    :template_title => '{*actor*} {*achievement_action*}', 
    :template_body => '{*comment*}' 
  }, 
  { 
    :template_title => '{*actor*} used <a href="http://apps.facebook.com/becounted">BeCounted</a> to make their vote count', 
    :template_body => 'Voting is as easy as 1-2-3 with <a href="http://apps.facebook.com/becounted">BeCounted</a>' 
  }, 
]
full_story_template = { 
  :template_title => '{*actor*} {*achievement_action*}', 
  :template_body => '{*comment*}'
} 

fbsession = Facebooker::Session.create(ENV['FACEBOOK_API_KEY'], ENV['FACEBOOK_SECRET_KEY'])
#template_id = fbsession.register_template_bundle(one_line_story_templates, short_story_templates, full_story_template)
template_id = fbsession.register_template_bundle(one_line_story_templates)
puts 'Add the following line to config/initializers/becounted.rb'
puts "FACEBOOK_FEED_TEMPLATE_ID = #{template_id}"
