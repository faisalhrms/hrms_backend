class CreateAttendanceStructures < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_structures do |t|
			t.string 		:name
			t.string 		:code
			t.integer 	:company_id
			t.boolean 	:is_active, :default => false
			t.integer 	:location_id
			t.integer 	:branch_id
			t.integer 	:department_id
			t.integer 	:grade_id
			t.datetime 	:start_date
			t.datetime 	:end_date
			t.integer 	:absent_policy_id
			t.integer 	:attendance_overtime_id
			t.integer 	:attendance_relaxation_id
			t.integer 	:early_left_id
			t.integer 	:missing_punch_id
			t.text 			:description
      t.timestamps
    end
    add_index :attendance_structures, :company_id
    add_index :attendance_structures, :location_id
    add_index :attendance_structures, :branch_id
    add_index :attendance_structures, :department_id
    add_index :attendance_structures, :grade_id
    add_index :attendance_structures, :absent_policy_id
    add_index :attendance_structures, :attendance_overtime_id
    add_index :attendance_structures, :attendance_relaxation_id
    add_index :attendance_structures, :early_left_id
    add_index :attendance_structures, :missing_punch_id
  end
end
