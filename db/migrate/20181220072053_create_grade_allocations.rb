class CreateGradeAllocations < ActiveRecord::Migration[7.1]
  def change
    create_table :grade_allocations do |t|
    	t.integer 	:company_id
    	t.integer 	:location_id
    	t.integer 	:branch_id
    	t.string 		:name
    	t.text			:description
      t.timestamps
    end
    add_index :grade_allocations, :company_id
    add_index :grade_allocations, :location_id
    add_index :grade_allocations, :branch_id
  end
end
