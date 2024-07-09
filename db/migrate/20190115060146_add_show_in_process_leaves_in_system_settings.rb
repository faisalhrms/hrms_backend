class AddShowInProcessLeavesInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :in_process_leave_allowed, :boolean, :default => false
  end
end
