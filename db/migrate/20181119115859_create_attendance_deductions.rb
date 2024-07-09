class CreateAttendanceDeductions < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_deductions do |t|
    	t.integer 	:company_id
			t.integer 	:attendance_type_id
			t.string 		:name
			t.string 		:deduction_from
			t.string 		:deduction_type
			t.float 		:exempted_in_month, :default => 0.0
			t.float 		:deduction_value, 	:default => 0.0
			t.text 			:description
      t.timestamps
    end
    add_index :attendance_deductions, :company_id
    add_index :attendance_deductions, :attendance_type_id
  end
end
