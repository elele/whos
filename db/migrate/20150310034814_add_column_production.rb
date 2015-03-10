class AddColumnProduction < ActiveRecord::Migration
  def change
    add_column :whos_user_devices, :production, :integer
  end
end
