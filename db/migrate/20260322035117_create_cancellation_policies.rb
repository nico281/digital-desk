class CreateCancellationPolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :cancellation_policies do |t|
      t.references :professional, null: false, foreign_key: true, index: { unique: true }
      t.integer :free_cancel_hours_before, default: 24, null: false
      t.integer :late_cancel_refund_percent, default: 0, null: false

      t.timestamps
    end
  end
end
