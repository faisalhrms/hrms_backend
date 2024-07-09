class AddArrearOptionInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :arrear_overtime, 				:boolean, :default => false
  	add_column :system_settings, :arrear_new_joiner, 			:boolean, :default => false
  	add_column :system_settings, :arrear_off_day_payment, :boolean, :default => false
  end
end
