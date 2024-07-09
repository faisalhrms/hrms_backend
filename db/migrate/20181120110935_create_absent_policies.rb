class CreateAbsentPolicies < ActiveRecord::Migration[7.1]
  def change
    create_table :absent_policies do |t|
    	t.integer 	:company_id
    	t.integer 	:attendance_deduction_id
    	t.integer 	:fallback_id
			t.string 		:name
			t.string 		:code
			t.boolean		:is_active, :default => true
			t.text 			:description
      t.timestamps
    end
    add_index :absent_policies, :company_id
    add_index :absent_policies, :attendance_deduction_id
    add_index :absent_policies, :fallback_id
  end
end
