class WhosCustomMessage < ActiveRecord::Base
  include OPE::Jpush
  belongs_to :user
  belongs_to :reveice, class_name: "User"
  has_one :whos_user_device ,:through => :reveice
  after_create :pushout

  def options
     {}
  end


end
