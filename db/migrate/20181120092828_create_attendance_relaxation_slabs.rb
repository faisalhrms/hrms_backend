class CreateAttendanceRelaxationSlabs < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_relaxation_slabs do |t|
    	t.integer 	:attendance_relaxation_id
    	t.integer 	:attendance_deduction_id
    	t.integer 	:fallback_id
    	t.float 		:start_minute, 	:default => 0.0
    	t.float 		:end_minute, 		:default => 0.0
      t.timestamps
    end
    add_index :attendance_relaxation_slabs, :attendance_relaxation_id
    add_index :attendance_relaxation_slabs, :attendance_deduction_id
    add_index :attendance_relaxation_slabs, :fallback_id
  end
end
