class CreateEmployeeArrears < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_arrears do |t|
    	t.integer 	:employee_id
			t.integer 	:offical_duty_id
			t.integer 	:leave_request_id
			t.float 		:arrear_days, :default => 0.0
			t.string 		:arrear_type
			t.datetime 	:start_date
			t.datetime 	:end_date
			t.datetime 	:arrears_month
      t.timestamps
    end
    add_index :employee_arrears, :employee_id
    add_index :employee_arrears, :offical_duty_id
    add_index :employee_arrears, :leave_request_id
  end
end
