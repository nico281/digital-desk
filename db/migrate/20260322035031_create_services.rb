class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.references :professional, null: false, foreign_key: true
      t.references :category
      t.string :title
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.integer :duration_minutes
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
