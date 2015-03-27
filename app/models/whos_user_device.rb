class WhosUserDevice < ActiveRecord::Base

  def production
    self['production'].to_s == '1' ? true : false
  end
end
