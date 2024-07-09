class CreateAttendanceOvertimeSlabs < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_overtime_slabs do |t|
    	t.integer 	:attendance_overtime_id
    	t.integer 	:attendance_earning_id
    	t.float 		:min_minute, 	:default => 0.0
    	t.float 		:max_minute, 		:default => 0.0
      t.timestamps
    end
    add_index :attendance_overtime_slabs, :attendance_overtime_id
    add_index :attendance_overtime_slabs, :attendance_earning_id
  end
end
