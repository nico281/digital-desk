class AddBlockSettingsToProfessionals < ActiveRecord::Migration[8.0]
  def change
    add_column :professionals, :block_duration_minutes, :integer, default: 60, null: false
    add_column :professionals, :buffer_minutes, :integer, default: 0, null: false
  end
end
