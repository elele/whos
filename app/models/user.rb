class User < ActiveRecord::Base
  has_many :whos_friends
  has_many :friends, :class_name => "User", :through => :whos_friends, :source => :friend
  has_many :whos_custom_messages
  has_one :whos_user_device


  validates_uniqueness_of :user_name, :phone_no, :on => :create
  mount_uploader :icon_path, AvatarUploader

  def self.auth(phone, password)
    User.find_by(:phone_no => phone, password: password)
  end
end
