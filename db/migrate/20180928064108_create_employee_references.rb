class CreateEmployeeReferences < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_references do |t|
			t.integer 		:employee_id
			t.string 			:reference_type
			t.string 			:name
			t.string 			:email
			t.string 			:contact_number
			t.string 			:organization
			t.string 			:designation
			t.text 				:address
      t.timestamps
    end
    add_index :employee_references, :employee_id
  end
end
