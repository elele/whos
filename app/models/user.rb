class User < ActiveRecord::Base
  has_many :whos_friends
  has_many :friends, :class_name => "User", :through => :whos_friends, :source => :friend
  has_many :whos_custom_messages
  has_one :whos_user_device

  mount_uploader :icon_path, AvatarUploader
  validates_uniqueness_of :user_name, :phone_no

  def self.auth(phone, password)
    User.find_by(:phone => phone, password: password)
  end
end
