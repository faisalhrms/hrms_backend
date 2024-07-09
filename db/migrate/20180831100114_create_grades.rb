class CreateGrades < ActiveRecord::Migration[7.1]
  def change
    create_table :grades do |t|
    	t.string 		:name
			t.string 		:code
			t.integer 	:company_id
			t.string 		:currency_title
			t.boolean		:is_active, :default => true
			t.text 			:description
      t.timestamps
    end
    add_index :grades, :company_id
  end
end
