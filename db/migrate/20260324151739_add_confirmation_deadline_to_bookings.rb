class AddConfirmationDeadlineToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :confirmation_deadline_at, :datetime
  end
end
