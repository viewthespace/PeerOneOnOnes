class User < ActiveRecord::Base
  has_many :primary_meetings, class_name: "Meeting", foreign_key: "primary_user_id"
  has_many :secondary_meetings, class_name: "Meeting", foreign_key: "secondary_user_id"

  def meetings
    primary_meetings + secondary_meetings
  end
end
