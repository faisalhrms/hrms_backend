class AddNoOfMonthInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :confirmation_type, 	:string, 	:default => "Day"
		add_column :system_settings, :no_of_month, 				:float, 	:default => 0.0
		add_column :system_settings, :subtracted_days, 		:float, 	:default => 0.0
  end
end
