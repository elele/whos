class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :phone_no
      t.string :password
      t.string :icon_path
      t.integer :status, :default => 1
      t.timestamps null: false
    end
  end
end
