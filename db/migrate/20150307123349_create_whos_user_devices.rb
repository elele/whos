class CreateWhosUserDevices < ActiveRecord::Migration
  def change
    create_table :whos_user_devices do |t|
      t.belongs_to :user
      t.string :system
      t.string :model
      t.string :imei
      t.string :devicetoken
      t.string :currentversion
      t.string :lng
      t.string :lat
      t.integer :status, :default => 1
      t.timestamps null: false
    end
  end
end
