class CreateAvailabilityBlocks < ActiveRecord::Migration[8.0]
  def change
    create_table :availability_blocks do |t|
      t.references :professional, null: false, foreign_key: true
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :status, default: 0, null: false
      t.references :booking, foreign_key: true

      t.timestamps
    end

    add_index :availability_blocks, [ :professional_id, :date, :start_time ], unique: true
    add_index :availability_blocks, :status
  end
end
