class CreateAvailabilitySchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :availability_schedules do |t|
      t.references :professional, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false

      t.timestamps
    end

    add_index :availability_schedules, [:professional_id, :day_of_week]
  end
end
