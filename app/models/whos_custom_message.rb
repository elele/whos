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
    {
        uid: user.id,
        fuid: reveice.id,
        type: message_type,
        path: path,
        content: {

            lat: lat,
            lng: lng,
            user_name: user.user_name
        }
    }
  end


end
