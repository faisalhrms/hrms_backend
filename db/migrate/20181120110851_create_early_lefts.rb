class CreateEarlyLefts < ActiveRecord::Migration[7.1]
  def change
    create_table :early_lefts do |t|
    	t.integer 	:company_id
			t.string 		:name
			t.string 		:code
			t.boolean		:is_active, :default => true
			t.text 			:description
      t.timestamps
    end
    add_index :early_lefts, :company_id
  end
end
