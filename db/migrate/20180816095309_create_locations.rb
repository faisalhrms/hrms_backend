class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
    	t.integer 	:company_id
    	t.string 		:name
    	t.string 		:code
    	t.text			:description
    	t.boolean		:is_active, :default => true
      t.timestamps
    end
    add_index :locations, :company_id
  end
end
