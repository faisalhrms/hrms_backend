class CreateEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_attendances do |t|
			t.integer  :employee_id
			t.integer  :company_id
			t.integer  :location_id
			t.integer  :branch_id
			t.integer  :department_id
			t.integer  :sub_department_id
			t.integer  :grade_id
			t.integer  :job_title_id
			t.integer  :designation_id
			t.integer  :salary_unit_id
			t.integer  :cost_center_id
			t.integer  :roster_id
			
			t.string   :employee_full_name
			t.string   :employee_code
			t.string   :company_name
			t.string   :location_name
			t.string   :branch_name
			t.string   :department_name
			t.string   :sub_department_name
			t.string   :grade_name
			t.string   :job_title_name
			t.string   :designation_name
			t.string   :salary_unit_name
			t.string   :cost_center_name
			t.string   :attendance_status
			t.string   :early_left_status
			
			t.datetime :attendance_date
			t.datetime :office_start_time
			t.datetime :office_end_time
			t.datetime :in_time
			t.datetime :out_time	
			t.datetime :office_in_time
			t.datetime :office_out_time
			t.datetime :buffer_office_in_time
			t.datetime :buffer_office_out_time		
			
			t.float    :early_left_deduction, 			:default => 0.0
			t.float    :checkin_deduction, 					:default => 0.0
			t.float    :salary_deduction, 					:default => 0.0
			t.float    :over_time_seconds, 					:default => 0.0
			t.float    :over_time_hours, 						:default => 0.0
			t.float    :off_days_payment_days, 			:default => 0.0
			t.float    :no_of_cpl, 									:default => 0.0
			t.float    :remaining_working_hour, 		:default => 0.0

			t.float    :office_start_hour, 					:default => 0.0
			t.float    :office_start_min, 					:default => 0.0
			t.float    :office_end_hour, 						:default => 0.0
			t.float    :office_end_min, 						:default => 0.0
			t.float    :start_buffer, 							:default => 0.0
			t.float    :end_buffer, 								:default => 0.0
			t.float    :buffer_office_start_hour, 	:default => 0.0
			t.float    :buffer_office_start_min, 		:default => 0.0
			t.float    :buffer_office_end_hour, 		:default => 0.0
			t.float    :buffer_office_end_min, 			:default => 0.0
			
			t.boolean  :is_rest_day, 						:default => false
			t.boolean  :is_public_holiday, 			:default => false
			t.boolean  :attendance_exemption, 	:default => false
			t.boolean  :mark_as_manual, 				:default => false
			t.boolean  :roster_exist, 					:default => false
			t.boolean  :is_finalize, 						:default => false
			t.boolean  :is_on_leave, 						:default => false
			t.boolean  :is_overtime, 						:default => false
			t.boolean  :is_off_day_working, 		:default => false
			t.boolean  :is_cpl, 								:default => false
			t.boolean  :attendance_exempted, 		:default => false

			t.text     :remarks
      t.timestamps
    end
    add_index :employee_attendances, :employee_id
		add_index :employee_attendances, :company_id
		add_index :employee_attendances, :location_id
		add_index :employee_attendances, :branch_id
		add_index :employee_attendances, :department_id
		add_index :employee_attendances, :sub_department_id
		add_index :employee_attendances, :grade_id
		add_index :employee_attendances, :job_title_id
		add_index :employee_attendances, :designation_id
		add_index :employee_attendances, :salary_unit_id
		add_index :employee_attendances, :cost_center_id
		add_index :employee_attendances, :roster_id
  end
end





				