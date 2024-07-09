class CreateTaxSlabDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :tax_slab_details do |t|
			t.integer 	:tax_slab_id
			t.float 		:lower_limit, 		:default => 0.0
			t.float 		:upper_limit, 		:default => 0.0
			t.float 		:tax_percentage, 	:default => 0.0
			t.float 		:fixed_amount, 		:default => 0.0
      t.timestamps
    end
    add_index :tax_slab_details, :tax_slab_id
  end
end
