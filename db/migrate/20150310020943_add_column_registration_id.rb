class AddColumnRegistrationId < ActiveRecord::Migration
  def change
    add_column :whos_user_devices, :registration_id, :integer
  end
end
