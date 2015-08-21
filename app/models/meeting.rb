class Meeting < ActiveRecord::Base
  belongs_to :primary_user, class_name: "User"
  belongs_to :secondary_user, class_name: "User"

  # def self.find_any_matches id1, id2
  #   Meeting.where(primary_user_id: id1, secondary_user_id: id2)
  # end

  def archive
    self.update_attributes(archived_at: Time.now)
  end
end
