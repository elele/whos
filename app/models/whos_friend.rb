class WhosFriend < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  scope :white_list, -> { where(:black => false) }
  default_scope { order(:recent_time => :desc) }
end
