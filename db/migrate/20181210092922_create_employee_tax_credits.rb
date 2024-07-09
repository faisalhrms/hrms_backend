class CreateEmployeeTaxCredits < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_tax_credits do |t|
    	t.integer 	:employee_id
      t.integer   :company_id
    	t.integer 	:fiscal_year_id
      t.datetime  :tax_credit_month
      t.string    :tax_credit_formatted_month
    	t.float 		:tax_credit_amount, :default => 0.0
    	t.string 		:tax_credit_type
      t.timestamps
    end
    add_index :employee_tax_credits, :company_id
    add_index :employee_tax_credits, :employee_id
    add_index :employee_tax_credits, :fiscal_year_id
  end
end
