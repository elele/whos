class WhosFriend < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  scope :white_list, -> { where(:black => false) }
  default_scope { order(:recent_time => :desc) }

  before_create :set_recent_time,:add_custom_message

  def set_recent_time
    self.recent_time = Time.now
  end


  def add_custom_message

  end
end
