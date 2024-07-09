class CreateFixedPayItems < ActiveRecord::Migration[7.1]
  def change
    create_table :fixed_pay_items do |t|
    	t.integer 		:company_id
    	t.integer 		:employee_id
    	t.integer 		:pay_item_id
    	t.float 			:item_amount, 	:default => 0.0
    	t.boolean 		:is_active, 		:default => false
      t.timestamps
    end
    add_index :fixed_pay_items, :company_id
    add_index :fixed_pay_items, :employee_id
    add_index :fixed_pay_items, :pay_item_id
  end
end
