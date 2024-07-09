class CreatePayInvoiceDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :pay_invoice_details do |t|
			t.integer 		:item_id
			t.integer 		:pay_invoice_id
			t.integer 		:sort_order, 						:default => 0
			t.string 			:item_type
			t.string 			:item_name
			t.float 			:amount, 								:default => 0.0
			t.float 			:taxable_amount, 				:default => 0.0
			t.boolean 		:show_in_slip, 					:default => false
			t.boolean 		:part_of_other, 				:default => false
			t.boolean 		:part_of_gross_salary, 	:default => false
      t.timestamps
    end
    add_index :pay_invoice_details, :item_id
    add_index :pay_invoice_details, :pay_invoice_id
  end
end
