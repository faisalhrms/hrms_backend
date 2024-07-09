class AddOdRestrictionInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :od_restriction, :boolean, :default => false
		add_column :system_settings, :od_message, 		:text, :default => ""
		add_column :system_settings, :od_start_date, 	:datetime
		add_column :system_settings, :od_end_date, 		:datetime
  end
end
