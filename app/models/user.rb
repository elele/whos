class User < ActiveRecord::Base
  has_many :whos_friends #, -> { where(:black => false) }
  has_many :valid_who_friends, -> { where(:black => false) }, :class_name => "WhosFriend"
  has_many :invalid_who_friends, -> { where(:black => true) }, :class_name => "WhosFriend"
  has_many :friends, :class_name => "User", :through => :whos_friends, :source => :friend
  has_many :valid_friends, :class_name => "User", :through => :valid_who_friends, :source => :friend
  has_many :whos_custom_messages
  has_one :whos_user_device

  after_create :add_whos


  validates_uniqueness_of :user_name, :phone_no, :on => :create
  mount_uploader :icon_path, AvatarUploader

  def self.auth(phone, password)
    User.find_by(:phone_no => phone, password: password)
  end

  def icon
    "http://121.40.163.143" + self.icon_path.url(:thumb) || ''
  end

  def add_whos
    self.friends << User.whos_user
  end


  def to_friends(friends)
    return [] if friends.blank?
    friends.delete_if { |f| f.invalid_who_friends.include?(self) }
    self.valid_friends & friends
  end


  def self.whos_user
    self.find_by(:id => 1)
  end
end
