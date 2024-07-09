class CreatePayItems < ActiveRecord::Migration[7.1]
  def change
    create_table :pay_items do |t|
    	t.integer 	:company_id
			t.string 		:eligible_from
			t.string 		:name
			t.string 		:code
			t.string 		:item_type
			t.string 		:calculation_type
			t.boolean 	:is_active, 								:default => false
			t.boolean 	:show_in_slip, 							:default => false
			t.boolean 	:part_of_other, 						:default => false
			t.boolean 	:is_taxable, 								:default => false
			t.float 		:exempted_tax_percentage,   :default => 0.0
			t.string 		:formula
			t.boolean 	:is_bonus, 									:default => false
			t.datetime 	:bonus_date
			t.string 		:bonus_month
			t.text 			:formula_with_code
			t.text 			:description
      t.timestamps
    end
    add_index :pay_items, :company_id
  end
end
