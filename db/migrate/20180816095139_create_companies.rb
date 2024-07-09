class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
    	t.string 		:name
    	t.string 		:code
    	t.string 		:short_name
    	t.text			:address
    	t.text			:description
    	t.boolean		:is_active, :default => true
      t.timestamps
    end
  end
end
