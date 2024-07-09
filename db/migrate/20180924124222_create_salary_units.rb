class CreateSalaryUnits < ActiveRecord::Migration[7.1]
  def change
    create_table :salary_units do |t|
    	t.integer 	:company_id
    	t.string 		:name
    	t.boolean		:is_active, :default => true
    	t.text			:description
      t.timestamps
    end
    add_index :salary_units, :company_id
  end
end
