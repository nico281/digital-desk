class CreateChatReadMarkers < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_read_markers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true
      t.datetime :last_read_at, null: false

      t.timestamps
    end
    add_index :chat_read_markers, [ :user_id, :booking_id ], unique: true
  end
end
