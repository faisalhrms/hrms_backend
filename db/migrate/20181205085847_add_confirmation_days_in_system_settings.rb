class AddConfirmationDaysInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :confirmation_days, 	:float, 	:default => 0.0
  end
end
