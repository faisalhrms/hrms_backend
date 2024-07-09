class AddLeaveDeductionInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :live_leave_earning, 	:boolean, :default => false
  	add_column :system_settings, :live_leave_deduction, :boolean, :default => false
  end
end
