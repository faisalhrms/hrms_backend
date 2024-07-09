class CreateDepartmentAllocations < ActiveRecord::Migration[7.1]
  def change
    create_table :department_allocations do |t|
    	t.integer 	:company_id
    	t.integer 	:location_id
    	t.integer 	:branch_id
    	t.string 		:name
    	t.text			:description
      t.timestamps
    end
    add_index :department_allocations, :company_id
    add_index :department_allocations, :location_id
    add_index :department_allocations, :branch_id
  end
end
