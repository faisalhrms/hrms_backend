class CreateEmployeeNextOfKins < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_next_of_kins do |t|
			t.integer 		:employee_id
			t.integer 		:employee_relative_id
			t.integer 		:relationship_id
			t.float 			:relative_age, 		:default => 0.0
			t.float 			:percentage, 			:default => 0.0
      t.timestamps
    end
    add_index :employee_next_of_kins, :employee_id
    add_index :employee_next_of_kins, :employee_relative_id
    add_index :employee_next_of_kins, :relationship_id
  end
end
