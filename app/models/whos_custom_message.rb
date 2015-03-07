class WhosCustomMessage < ActiveRecord::Base
  include OPE::Jpush
  belongs_to :user
  belongs_to :reveice, class_name: "User"

  after_create :pushout

  def options


  end


end
