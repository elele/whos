class CreateWhosFriends < ActiveRecord::Migration
  def change
    create_table :whos_friends do |t|
      t.belongs_to :user
      t.belongs_to :friend
      t.integer :status, :default => 1
      t.string :remark
      t.boolean :black
      t.timestamps null: false
    end
  end
end
