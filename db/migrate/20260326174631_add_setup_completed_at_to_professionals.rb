class AddSetupCompletedAtToProfessionals < ActiveRecord::Migration[8.0]
  def change
    add_column :professionals, :setup_completed_at, :datetime

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE professionals
          SET setup_completed_at = updated_at
          WHERE headline IS NOT NULL
            AND headline != ''
            AND id IN (SELECT professional_id FROM services)
            AND id IN (SELECT professional_id FROM availability_schedules)
        SQL
      end
    end
  end
end
