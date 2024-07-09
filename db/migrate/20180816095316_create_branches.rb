class CreateBranches < ActiveRecord::Migration[7.1]
  def change
    create_table :branches do |t|
    	t.integer 	    :company_id
    	t.integer 	    :location_id
    	t.string 		:country_id
    	t.string 		:state_id
    	t.string 		:city_id
    	t.string 		:name
    	t.string 		:code
    	t.text			:description
    	t.boolean		:is_active, :default => true
      t.timestamps
    end
    add_index :branches, :company_id
    add_index :branches, :location_id
    add_index :branches, :country_id
    add_index :branches, :state_id
    add_index :branches, :city_id
  end
end
