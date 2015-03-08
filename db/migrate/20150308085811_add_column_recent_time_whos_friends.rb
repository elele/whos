class AddColumnRecentTimeWhosFriends < ActiveRecord::Migration
  def change
    add_column :whos_friends, :recent_time, :datetime
  end
end
