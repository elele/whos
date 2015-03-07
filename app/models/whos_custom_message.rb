class WhosCustomMessage < ActiveRecord::Base
  include OPE::JPush
  belongs_to :user
  belongs_to :reveice, class_name: "User"

  after_create :pushout

  def options


  end


end
