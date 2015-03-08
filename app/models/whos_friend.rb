class WhosFriend < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  scope :white_list, -> { where(:black => false) }
end
