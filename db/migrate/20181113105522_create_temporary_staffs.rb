class CreateTemporaryStaffs < ActiveRecord::Migration[7.1]
  def change
    create_table :temporary_staffs do |t|
			t.string 		:salutation
			t.string 		:first_name
			t.string 		:last_name
			t.string 		:father_name
			t.string 		:official_email
			t.string 		:official_mobile_number
			t.string 		:personal_email
			t.string 		:personal_number
			t.datetime 	:date_of_birth
			t.string 		:gender
			t.string 		:cnic_number
			t.string 		:blood_group
			t.string 		:martial_status
			t.string 		:gross_salary, 		:default => 0.0
			t.integer 	:company_id
			t.integer 	:location_id
			t.integer 	:branch_id
			t.integer 	:department_id
			t.integer 	:grade_id
			t.integer 	:designation_id
			t.integer 	:job_title_id
			t.integer 	:salary_unit_id
			t.integer 	:cost_center_id
			t.datetime 	:joining_date
			t.string 		:temporary_staff_code
			t.boolean 	:is_active, 			:default => false
			t.text 			:current_address
      t.timestamps
    end
  end
end
