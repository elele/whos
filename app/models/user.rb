class User < ActiveRecord::Base
  has_many :whos_friends, -> { where(:black => false) }
  has_many :all_whos_friends, :class_name => "WhosFriend"
  has_many :friends, :class_name => "User", :through => :whos_friends, :source => :friend
  has_many :whos_custom_messages
  has_one :whos_user_device

  after_create :add_whos


  validates_uniqueness_of :user_name, :phone_no, :on => :create
  mount_uploader :icon_path, AvatarUploader

  def self.auth(phone, password)
    User.find_by(:phone_no => phone, password: password)
  end

  def icon
    self.icon_path.url(:thumb) || ''
  end

  def add_whos
    self.friends << User.whos_user
  end


  def self.whos_user
    self.where(:user_name => "Who's机器人", :phone_no => '8888888888', :password => '123456', :id => 1).first_or_create
  end
end
