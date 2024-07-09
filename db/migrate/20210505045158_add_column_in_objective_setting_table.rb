class AddColumnInObjectiveSettingTable < ActiveRecord::Migration[7.1]
  def change
    add_column  :objective_settings, :fiscal_year_id, :integer
  end
end
