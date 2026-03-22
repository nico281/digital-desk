class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.references :parent, foreign_key: { to_table: :categories }

      t.timestamps
    end

    add_index :categories, :slug, unique: true
  end
end
