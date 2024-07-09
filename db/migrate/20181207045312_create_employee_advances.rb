class CreateEmployeeAdvances < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_advances do |t|
    	t.integer		:company_id
			t.integer		:employee_id
			t.float			:gross_salary, 						:default => 0.0
			t.float			:advance_amount, 					:default => 0.0
			t.float			:advance_percentage, 			:default => 0.0
			t.datetime	:advance_date
			t.datetime	:pay_back_date
			t.string		:pay_back_month
			t.boolean		:is_cleared, 							:default => false
      t.timestamps
    end
    add_index :employee_advances, :company_id
    add_index :employee_advances, :employee_id
  end
end
