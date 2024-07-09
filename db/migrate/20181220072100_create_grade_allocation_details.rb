class CreateGradeAllocationDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :grade_allocation_details do |t|
    	t.integer		:grade_allocation_id
    	t.integer		:grade_id
    	t.boolean		:is_selected,	:default => false
      t.timestamps
    end
    add_index :grade_allocation_details, :grade_allocation_id
    add_index :grade_allocation_details, :grade_id
  end
end
