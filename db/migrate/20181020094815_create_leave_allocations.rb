class CreateLeaveAllocations < ActiveRecord::Migration[7.1]
  def change
    create_table :leave_allocations do |t|
    	t.integer 	:company_id
			t.integer 	:employee_id
			t.integer 	:leave_type_id
      t.timestamps
    end
    add_index :leave_allocations, :company_id
    add_index :leave_allocations, :employee_id
    add_index :leave_allocations, :leave_type_id
  end
end
