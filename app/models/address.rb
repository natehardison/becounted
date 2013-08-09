class Address < ActiveRecord::Base
  has_many :counties
  has_many :states
  has_many :towns
  
  def to_html
    str = "<p style='text-align: center'>"
    str += self[:line_1] + "<br />" if self[:line_1]
    str += self[:line_2] + "<br />" if self[:line_2]
    str += self[:line_3] + "<br />" if self[:line_3]
    str += self[:line_4] + "<br />" if self[:line_4]
    str += self[:line_5] + "<br />" if self[:line_5]
    str += self[:city] + "&nbsp;" if self[:city]
    str += self[:state] + ",&nbsp;" if self[:state]
    str += self[:zip] if self[:zip]
    return str + "</p>"
  end
end
