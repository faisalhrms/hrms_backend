class CreatePayExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :pay_executions do |t|
			t.string 		:name
			t.integer 	:company_id
			t.integer 	:location_id
			t.integer 	:provident_fund_id
			t.integer 	:eobi_id
			t.integer 	:tax_slab_id
			t.integer 	:fiscal_year_id
			t.datetime 	:pay_month
			t.string 		:formated_pay_month
			t.boolean 	:tax_applicable, 								:default => false
			t.boolean 	:is_executed, 									:default => false
			t.float 		:no_of_pay_days, 								:default => 0.0
      t.timestamps
    end
    add_index :pay_executions, :company_id
    add_index :pay_executions, :location_id
    add_index :pay_executions, :provident_fund_id
    add_index :pay_executions, :eobi_id
    add_index :pay_executions, :tax_slab_id
    add_index :pay_executions, :fiscal_year_id
  end
end
