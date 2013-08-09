class AbsenteeHurdle < ActiveRecord::Base
  belongs_to :state
  
  def to_html
    html = "<h5>#{self.title}</h5><ul>"
    html += "<li>#{self.part_1}</li>" unless self.part_1.blank?
    html += "<li>#{self.part_2}</li>" unless self.part_2.blank?
    html += "<li>#{self.part_3}</li>" unless self.part_3.blank?
    html += "<li>#{self.part_4}</li>" unless self.part_4.blank?
    html += "<li>#{self.part_5}</li>" unless self.part_5.blank?
    html += "<li>#{self.part_6}</li>" unless self.part_6.blank?
    html += "<li>#{self.part_7}</li>" unless self.part_7.blank?
    html += "<li>#{self.part_8}</li>" unless self.part_8.blank?
    html += "<li>#{self.part_9}</li>" unless self.part_9.blank?
    html += "<li>#{self.part_10}</li>" unless self.part_10.blank?
    html += "<li>#{self.part_11}</li>" unless self.part_11.blank?
    html += "<li>#{self.part_12}</li>" unless self.part_12.blank?
    html += "</ul>"
  end
end
