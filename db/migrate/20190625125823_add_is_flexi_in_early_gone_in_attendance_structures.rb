class AddIsFlexiInEarlyGoneInAttendanceStructures < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_structures, :is_flexi_in_early_gone, 					:boolean, :default => false
  	add_column :attendance_structures, :early_gone_total_working_minute, 	:float, 	:default => 0.0
  end
end
