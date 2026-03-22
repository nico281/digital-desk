class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :professional, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end
  end
end
