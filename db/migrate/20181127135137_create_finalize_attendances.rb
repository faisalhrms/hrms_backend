class CreateFinalizeAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :finalize_attendances do |t|
			t.integer 	:employee_attendance_id
			t.integer 	:attendance_cutoff_id
			t.integer 	:employee_id
			t.integer 	:company_id
			t.integer 	:location_id
			t.integer 	:branch_id
			t.datetime 	:attendance_date
			t.float 		:arrear_days,						:default => 0.0
			t.float 		:pay_deduction,					:default => 0.0
			t.float 		:over_time_hours,				:default => 0.0
			t.float 		:over_time_minutes,			:default => 0.0
			t.float 		:over_time_seconds,			:default => 0.0
			t.float 		:off_day_payment,				:default => 0.0
			t.boolean 	:is_finalize,						:default => false
      t.timestamps
    end
    add_index :finalize_attendances, :employee_attendance_id
    add_index :finalize_attendances, :attendance_cutoff_id
    add_index :finalize_attendances, :employee_id
    add_index :finalize_attendances, :company_id
    add_index :finalize_attendances, :location_id
    add_index :finalize_attendances, :branch_id
  end
end
