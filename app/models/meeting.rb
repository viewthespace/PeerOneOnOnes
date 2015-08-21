class Meeting < ActiveRecord::Base
  belongs_to :primary_user, class_name: "User"
  belongs_to :secondary_user, class_name: "User"
end
