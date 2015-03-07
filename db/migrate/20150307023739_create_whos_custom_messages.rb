class CreateWhosCustomMessages < ActiveRecord::Migration
  def change
    create_table :whos_custom_messages do |t|
      t.belongs_to :user
      t.string :content
      t.string :path
      t.integer :message_type, :default => 0
      t.integer :status, :default => 1
      t.string :address
      t.string :lat
      t.string :lng
      t.timestamps null: false
    end
  end
end
