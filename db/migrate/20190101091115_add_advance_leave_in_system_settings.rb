class AddAdvanceLeaveInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :advance_leave_allowed, 	:boolean, :default => false
  	add_column :system_settings, :advance_leave_limit, 		:float, 	:default => 0.0
  end
end
