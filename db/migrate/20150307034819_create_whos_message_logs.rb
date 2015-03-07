class CreateWhosMessageLogs < ActiveRecord::Migration
  def change
    create_table :whos_message_logs do |t|
      t.belongs_to :from_user
      t.belongs_to :to_user
      t.belongs_to :message
      t.integer :status
      t.string :msg_code
      t.string :failed_msg
      t.timestamps null: false
    end

    add_column :whos_custom_messages, :reveice_id, :integer
  end
end
