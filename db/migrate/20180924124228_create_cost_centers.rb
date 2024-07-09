class CreateCostCenters < ActiveRecord::Migration[7.1]
  def change
    create_table :cost_centers do |t|
    	t.integer 	:company_id
    	t.integer 	:salary_unit_id
    	t.string 		:name
    	t.boolean		:is_active, :default => true
    	t.text			:description
      t.timestamps
    end
    add_index :cost_centers, :company_id
    add_index :cost_centers, :salary_unit_id
  end
end
