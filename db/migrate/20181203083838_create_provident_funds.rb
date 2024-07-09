class CreateProvidentFunds < ActiveRecord::Migration[7.1]
  def change
    create_table :provident_funds do |t|
			t.integer 		:company_id
			t.string 			:name
			t.boolean 		:is_active, 								:default => false
			t.string  	  :employee_value, 						:default => 0.0
			t.float   		:employee_fixed_amount, 		:default => 0.0
			t.float   		:employee_percentage, 			:default => 0.0
			t.integer 		:employee_pay_item_id
			t.string   		:employer_value, 						:default => 0.0
			t.float   		:employer_fixed_amount, 		:default => 0.0
			t.float   		:employer_percentage, 			:default => 0.0
			t.integer 		:employer_pay_item_id
			t.boolean 		:employer_taxable, 					:default => false
			t.float   		:employer_amount_exceed, 		:default => 0.0
			t.float   		:employer_tax_percentage, 	:default => 0.0
      t.timestamps
    end
    add_index :provident_funds, :company_id
    add_index :provident_funds, :employee_pay_item_id
    add_index :provident_funds, :employer_pay_item_id
  end
end
