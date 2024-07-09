class CreateBenefitStructures < ActiveRecord::Migration[7.1]
  def change
    create_table :benefit_structures do |t|
    	t.string 		:name
			t.string 		:code
			t.integer 	:company_id
			t.integer 	:location_id
			t.integer 	:grade_id
			t.integer 	:employee_type_id
			t.boolean		:is_active, :default => true
			t.text 			:description
      t.timestamps
    end
    add_index :benefit_structures, :company_id
    add_index :benefit_structures, :location_id
    add_index :benefit_structures, :grade_id
    add_index :benefit_structures, :employee_type_id
  end
end
