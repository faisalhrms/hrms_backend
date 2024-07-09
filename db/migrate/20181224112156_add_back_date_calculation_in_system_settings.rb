class AddBackDateCalculationInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :back_date_calculation, :boolean, :default => false
  end
end
