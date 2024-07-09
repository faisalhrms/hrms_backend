class AddOdUperCapInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :od_upper_cap_allowed, :boolean, :default => false
  	add_column :system_settings, :od_upper_cap_limit, 	:float, 	:default => 0.0

  	add_column :system_settings, :full_day_leave, 			:boolean, 	:default => true
  	add_column :system_settings, :half_day_leave, 			:boolean, 	:default => true
  	add_column :system_settings, :short_day_leave, 			:boolean, 	:default => true
  end
end
