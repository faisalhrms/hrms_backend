class CreateEmployeeLoans < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_loans do |t|
			t.integer		:company_id
			t.integer		:employee_id
			t.string		:loan_type
			t.float			:gross_salary, 					:default => 0.0
			t.float			:loan_amount, 					:default => 0.0
			t.float			:no_of_installment, 		:default => 0.0
			t.float			:monthly_installment, 	:default => 0.0
			t.float			:principle_loan_amount, :default => 0.0
			t.float			:annual_interest_rate, 	:default => 0.0
			t.boolean		:is_taxable, 						:default => false
			t.datetime	:loan_start_date
			t.datetime	:pay_back_date
      t.timestamps
    end
    add_index :employee_loans, :company_id
    add_index :employee_loans, :employee_id
  end
end
