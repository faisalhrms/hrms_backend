class CreateSubDepartments < ActiveRecord::Migration[7.1]
  def change
    create_table :sub_departments do |t|
    	t.integer 	:company_id
    	t.integer 	:department_id
    	t.string 		:name
    	t.string 		:code
    	t.text			:description
    	t.boolean		:is_active, :default => true
      t.timestamps
    end
    add_index :sub_departments, :company_id
    add_index :sub_departments, :department_id
  end
end
