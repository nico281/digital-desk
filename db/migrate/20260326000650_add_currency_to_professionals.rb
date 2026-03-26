class AddCurrencyToProfessionals < ActiveRecord::Migration[8.0]
  def change
    add_column :professionals, :currency, :string, default: "UYU", null: false
  end
end
