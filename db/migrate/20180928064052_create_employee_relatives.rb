class CreateEmployeeRelatives < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_relatives do |t|
			t.integer 		:employee_id
			t.string 			:relative_name
			t.integer 		:relationship_id
			t.string 			:email
			t.string 			:contact_number
			t.datetime 		:date_of_birth
			t.string 			:gender
			t.string 			:cnic_number
			t.boolean 		:is_dependent, :default => false
			t.text 				:address
      t.timestamps
    end
    add_index :employee_relatives, :employee_id
    add_index :employee_relatives, :relationship_id
  end
end
