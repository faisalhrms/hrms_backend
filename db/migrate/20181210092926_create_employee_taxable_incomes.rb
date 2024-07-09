class CreateEmployeeTaxableIncomes < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_taxable_incomes do |t|
    	t.integer 	:employee_id
      t.integer   :company_id
    	t.integer 	:fiscal_year_id
    	t.integer 	:pay_invoice_id
    	t.integer 	:pay_execution_id
    	t.float 		:current_taxable_amount, 			:default => 0.0
			t.float 		:prev_taxable_amount, 				:default => 0.0
			t.float 		:predicated_taxable_amount, 	:default => 0.0
			t.float 		:taxable_amount_to_date, 			:default => 0.0
			t.float 		:prev_incentive_amount, 			:default => 0.0
			t.float 		:current_incentive_amount, 		:default => 0.0
			t.float 		:loan_interest_amount, 				:default => 0.0
			t.float 		:gross_salary, 								:default => 0.0
			t.float 		:leave_enacashment_amount, 		:default => 0.0
			t.float 		:total_taxable_amount, 				:default => 0.0
			t.float 		:yearly_total_tax, 						:default => 0.0
			t.float 		:monthly_tax_amount, 					:default => 0.0
			t.float 		:total_paid_tax, 							:default => 0.0
			t.float 		:remaing_tax_to_be_paid, 			:default => 0.0
      t.boolean   :status,                      :default => true
      t.timestamps
    end
    add_index :employee_taxable_incomes, :company_id
    add_index :employee_taxable_incomes, :employee_id
    add_index :employee_taxable_incomes, :fiscal_year_id
    add_index :employee_taxable_incomes, :pay_invoice_id
    add_index :employee_taxable_incomes, :pay_execution_id
  end
end
