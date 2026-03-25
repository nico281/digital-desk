class AddIndexToBookingsConfirmationDeadlineAt < ActiveRecord::Migration[8.0]
  def change
    add_index :bookings, :confirmation_deadline_at
  end
end
