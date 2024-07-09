class AddDepartmentIdsInAttendanceStructures < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_structures, :department_ids, 	:text, 		:default => ""
  	add_column :attendance_structures, :special_rule, 		:boolean, :default => false
  	add_column :attendance_structures, :is_flexi, 				:boolean, :default => false
  	add_column :attendance_structures, :serve_minutes, 		:float, 	:default => 0.0
  end
end
