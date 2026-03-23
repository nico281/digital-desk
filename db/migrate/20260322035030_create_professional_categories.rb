class CreateProfessionalCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_categories do |t|
      t.references :professional, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :professional_categories, [ :professional_id, :category_id ], unique: true
  end
end
