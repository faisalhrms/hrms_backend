class CreateDepartments < ActiveRecord::Migration[7.1]
  def change
    create_table :departments do |t|
    	t.integer 	:company_id
    	t.string 		:name
    	t.string 		:code
    	t.text			:description
    	t.boolean		:is_active, :default => true
      t.timestamps
    end
    add_index :departments, :company_id
  end
end
