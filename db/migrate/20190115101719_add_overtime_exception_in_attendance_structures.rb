class AddOvertimeExceptionInAttendanceStructures < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_structures, :regular_overtime_exception, 		:boolean, 	:default => false
		add_column :attendance_structures, :regular_min_salary, 						:float, 		:default => 0.0
		add_column :attendance_structures, :regular_max_salary, 						:float, 		:default => 0.0
		add_column :attendance_structures, :regular_overtime_id, 						:integer
		add_column :attendance_structures, :holiday_overtime_exception, 		:boolean, 	:default => false
		add_column :attendance_structures, :holiday_min_salary, 						:float, 		:default => 0.0
		add_column :attendance_structures, :holiday_max_salary, 						:float, 		:default => 0.0
		add_column :attendance_structures, :holiday_overtime_id, 						:integer
  end
end
