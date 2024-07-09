class AddColumnsInObjectiveSettingsTable < ActiveRecord::Migration[7.1]
  def change
    add_column  :objective_settings,  :appraisal_status,  :string,  :default => "Pending"
    add_column  :objective_settings,  :line_manager_appraisal_approval, :string,  :default => "Pending"
  end
end
