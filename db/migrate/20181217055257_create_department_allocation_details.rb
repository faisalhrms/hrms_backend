class CreateDepartmentAllocationDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :department_allocation_details do |t|
    	t.integer		:department_allocation_id
    	t.integer		:department_id
    	t.boolean		:is_selected,								:default => false
      t.timestamps
    end
    add_index :department_allocation_details, :department_allocation_id
    add_index :department_allocation_details, :department_id
  end
end
