class CreateTaxSlabs < ActiveRecord::Migration[7.1]
  def change
    create_table :tax_slabs do |t|
    	t.integer 	:company_id
    	t.boolean   :is_active,   default: false
			t.string 		:name
			t.string 		:code
			t.text 			:description
      t.timestamps
    end
    add_index :tax_slabs, :company_id
  end
end
