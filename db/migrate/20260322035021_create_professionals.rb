class CreateProfessionals < ActiveRecord::Migration[8.0]
  def change
    create_table :professionals do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.text :bio
      t.string :headline
      t.boolean :verified, default: false
      t.float :rating_avg, default: 0.0
      t.integer :rating_count, default: 0
      t.boolean :require_confirmation, default: false

      t.timestamps
    end
  end
end
