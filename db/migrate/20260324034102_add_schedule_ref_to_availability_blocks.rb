class AddScheduleRefToAvailabilityBlocks < ActiveRecord::Migration[8.0]
  def change
    add_reference :availability_blocks, :availability_schedule, null: true, foreign_key: true
  end
end
