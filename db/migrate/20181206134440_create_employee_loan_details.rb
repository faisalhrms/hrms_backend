class CreateEmployeeLoanDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_loan_details do |t|
    	t.integer 	:employee_loan_id
    	t.datetime	:installment_date
			t.float 		:opening_balance, 							:default => 0.0
			t.float 		:installment_amount, 						:default => 0.0
			t.float 		:closing_balance, 							:default => 0.0
			t.float 		:principle_installment_amount, 	:default => 0.0
			t.float 		:loan_interest_amount, 					:default => 0.0
			t.boolean 	:is_cleared, 										:default => false
			t.string 		:status
			t.text 			:remarks
      t.timestamps
    end
    add_index :employee_loan_details, :employee_loan_id
  end
end
