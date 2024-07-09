class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
    	t.string			:salutation
			t.string			:first_name
			t.string			:last_name
			t.string			:father_name
			t.string			:official_email
			t.string			:official_mobile_number
			t.datetime		:date_of_birth
			t.string			:gender
			t.string			:cnic_number
			t.string			:blood_group
			t.string			:martial_status
			t.integer			:company_id
			t.integer			:location_id
			t.integer			:branch_id
			t.integer			:department_id
			t.integer			:designation_id
			t.integer			:job_title_id
			t.integer			:grade_id
			t.integer			:salary_unit_id
			t.integer			:cost_center_id
			t.datetime		:joining_date
			t.string			:employee_code
			t.string			:prev_employee_code
			t.boolean 		:on_probation, 								:default => true
			t.boolean 		:is_line_manager, 						:default => false
			t.boolean 		:is_active, 									:default => true
			t.boolean 		:create_login, 								:default => false
			t.integer			:relationship_id
			t.integer			:user_id
			t.string			:payment_method
			t.boolean 		:tax_exempted, 								:default => false
			t.boolean 		:salary_exempted, 						:default => false
			t.string			:bank_name
			t.string			:bank_branch_name
			t.string			:bank_branch_code
			t.string			:bank_account_title
			t.string			:bank_account_number
			t.float				:gross_salary, 								:default => 0.0
			t.boolean  		:is_admin,               			:default => false
	    t.boolean  		:custom_right,           			:default => false
	    t.integer  		:role_id
	    t.boolean  		:is_company_head,        			:default => false
	    t.boolean  		:is_location_head,       			:default => false
	    t.boolean  		:is_branch_head,         			:default => false
	    t.boolean  		:is_department_head,     			:default => false
	    t.string  		:user_account_email
	    t.string  		:user_account_password
	    t.string  		:emergency_contact_name
			t.string  		:emergency_contact_email
			t.string  		:emergency_contact_phone
      t.timestamps
    end
    add_index :employees, :company_id
		add_index :employees, :location_id
		add_index :employees, :branch_id
		add_index :employees, :department_id
		add_index :employees, :designation_id
		add_index :employees, :job_title_id
		add_index :employees, :grade_id
		add_index :employees, :salary_unit_id
		add_index :employees, :cost_center_id
		add_index :employees, :relationship_id
		add_index :employees, :user_id
		add_index :employees, :role_id
  end
end
