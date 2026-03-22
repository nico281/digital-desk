class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: 'ARS'
      t.integer :status, default: 0, null: false
      t.string :mp_payment_id

      t.timestamps
    end

    add_index :payments, :mp_payment_id
  end
end
