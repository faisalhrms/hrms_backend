class CreateSaleEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :sale_entries do |t|
			t.integer 	:company_id
			t.integer 	:location_id
			t.integer 	:branch_id
			t.string 		:name
			t.datetime 	:sale_month
			t.string 		:formated_month
			t.integer 	:sale_value, 		:default => 0.0
			t.integer 	:profit_value, 	:default => 0.0
			t.integer 	:loss_value, 		:default => 0.0
      t.timestamps
    end
  end
end
