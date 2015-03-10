class WhosCustomMessage < ActiveRecord::Base
  include OPE::Jpush
  belongs_to :user
  belongs_to :reveice, class_name: "User"
  has_one :send_whos_user_device, :through => :user, :class_name => "WhosUserDevice"
  has_one :whos_user_device, :through => :reveice

  before_create :set_reveice
  after_create :pushout

  def set_reveice
    if reveice == User.whos_user
      self.reveice = self.user
      self.message_type = 0
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
    end
  end


end
