class WhosCustomMessage < ActiveRecord::Base
  include OPE::Jpush
  belongs_to :user
  belongs_to :reveice, class_name: "User"
  has_one :send_whos_user_device, :through => :user, :class_name => "WhosUserDevice"
  has_one :whos_user_device, :through => :reveice

  before_create :set_reveice, :set_recent_time
  after_create :pushout

  def set_reveice
    if reveice == User.whos_user
      who_friend = WhosFriend.where(user: user, friend: reveice).first
      if who_friend
        who_friend.update_columns(recent_time: Time.now)
      end
      self.reveice = self.user
      self.message_type = 3
    end
  end

  def set_recent_time
    who_friend = WhosFriend.where(user: user, friend: reveice).first
    reveice_friend = WhosFriend.where(user: reveice, friend: user).first
    if who_friend && reveice_friend
      who_friend.update_columns(recent_time: Time.now)
      reveice_friend.update_columns(recent_time: Time.now)
    end
  end


  def options
    if message_type == 1
      {
          uid: user.id,
          lat: lat,
          lng: lng,
          type: message_type

      }
    elsif message_type == 2
      {type: message_type}
    elsif message_type == 3 or message_type == 0
      {
          uid: user.id,
          type: message_type
      }
    end
  end


end
