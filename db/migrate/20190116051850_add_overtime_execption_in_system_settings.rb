class AddOvertimeExecptionInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :overtime_execption, :boolean, :default => false
  end
end
