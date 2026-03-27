class AddConversationToMessagesAndChatReadMarkersAndBookings < ActiveRecord::Migration[8.0]
  def up
    # Add conversation_id columns
    add_reference :messages, :conversation, foreign_key: true
    add_reference :chat_read_markers, :conversation, foreign_key: true
    add_reference :bookings, :conversation, foreign_key: true

    # Make booking_id optional
    change_column_null :messages, :booking_id, true
    change_column_null :chat_read_markers, :booking_id, true

    # Backfill: create conversations for existing booking pairs
    execute <<~SQL
      INSERT INTO conversations (client_id, professional_id, created_at, updated_at)
      SELECT DISTINCT b.client_id, b.professional_id, MIN(b.created_at), MIN(b.created_at)
      FROM bookings b
      GROUP BY b.client_id, b.professional_id
    SQL

    # Link bookings to conversations
    execute <<~SQL
      UPDATE bookings
      SET conversation_id = (
        SELECT c.id FROM conversations c
        WHERE c.client_id = bookings.client_id
          AND c.professional_id = bookings.professional_id
      )
    SQL

    # Link messages to conversations via their booking
    execute <<~SQL
      UPDATE messages
      SET conversation_id = (
        SELECT b.conversation_id FROM bookings b
        WHERE b.id = messages.booking_id
      )
      WHERE booking_id IS NOT NULL
    SQL

    # Link chat_read_markers to conversations via their booking
    execute <<~SQL
      UPDATE chat_read_markers
      SET conversation_id = (
        SELECT b.conversation_id FROM bookings b
        WHERE b.id = chat_read_markers.booking_id
      )
      WHERE booking_id IS NOT NULL
    SQL

    # Now make conversation_id NOT NULL on messages and chat_read_markers
    change_column_null :messages, :conversation_id, false
    change_column_null :chat_read_markers, :conversation_id, false

    # Update indexes
    remove_index :messages, [ :booking_id, :created_at ] if index_exists?(:messages, [ :booking_id, :created_at ])
    add_index :messages, [ :conversation_id, :created_at ]

    remove_index :chat_read_markers, [ :user_id, :booking_id ] if index_exists?(:chat_read_markers, [ :user_id, :booking_id ])
    add_index :chat_read_markers, [ :user_id, :conversation_id ], unique: true
  end

  def down
    # Restore booking_id from conversation on messages
    execute <<~SQL
      UPDATE messages
      SET booking_id = (
        SELECT b.id FROM bookings b
        WHERE b.conversation_id = messages.conversation_id
        LIMIT 1
      )
      WHERE booking_id IS NULL
    SQL

    remove_index :messages, [ :conversation_id, :created_at ] if index_exists?(:messages, [ :conversation_id, :created_at ])
    remove_index :chat_read_markers, [ :user_id, :conversation_id ] if index_exists?(:chat_read_markers, [ :user_id, :conversation_id ])

    add_index :messages, [ :booking_id, :created_at ] unless index_exists?(:messages, [ :booking_id, :created_at ])
    add_index :chat_read_markers, [ :user_id, :booking_id ], unique: true unless index_exists?(:chat_read_markers, [ :user_id, :booking_id ])

    change_column_null :messages, :booking_id, false
    change_column_null :chat_read_markers, :booking_id, false

    remove_reference :bookings, :conversation
    remove_reference :chat_read_markers, :conversation
    remove_reference :messages, :conversation
  end
end
