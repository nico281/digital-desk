class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :professional, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.references :availability_block, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.references :payment, foreign_key: true
      t.string :meeting_url
      t.string :meeting_room_id

      t.timestamps
    end

    add_index :bookings, :status
  end
end
