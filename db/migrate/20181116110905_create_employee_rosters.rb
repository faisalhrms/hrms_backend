class CreateEmployeeRosters < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_rosters do |t|
			t.integer 		:employee_id
			t.integer 		:time_slot_id
			t.integer 		:company_id
			t.integer 		:location_id
			t.integer 		:branch_id
			t.integer 		:department_id
			t.integer 		:grade_id
			t.datetime 		:joining_date
			t.datetime 		:roster_date
			t.datetime  	:start_time
			t.datetime  	:end_time
			t.string 			:employee_code
			t.string  		:employee_name
			t.string  		:location_name
			t.string  		:branch_name
			t.string  		:department_name
			t.string  		:grade_name
			t.boolean  		:is_flexi, 					:default => false
			t.boolean  		:is_rest_day, 			:default => false
			t.boolean  		:is_transfer, 			:default => false
			t.string  		:formated_start_time
			t.string  		:formated_end_time
			t.float  			:start_buffer, 			:default => 0.0
			t.float  			:end_buffer, 				:default => 0.0
      t.timestamps
    end
  end
end
