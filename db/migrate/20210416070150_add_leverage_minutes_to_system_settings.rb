class AddLeverageMinutesToSystemSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :system_settings, :leverage_minutes, :boolean, :default => false
  end
end
