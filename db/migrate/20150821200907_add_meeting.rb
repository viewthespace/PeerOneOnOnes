class AddMeeting < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.integer :primary_user_id
      t.integer :secondary_user_id
      t.datetime :archived_at
      t.timestamps
    end
  end
end
