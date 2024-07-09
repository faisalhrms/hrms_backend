class CreateAssetDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :asset_details do |t|
    	t.integer 		:company_id
			t.string 			:item_name
			t.string 			:item_type
			t.string 			:item_model
			t.datetime 		:purchase_date
			t.datetime 		:expiry_date
			t.float 			:item_amount, 			:default => 0.0
			t.string 			:maturity_period
			t.string 			:engine_capacity
			t.string 			:engine_number
			t.string 			:chase_number
			t.string 			:sim_number
			t.string 			:emi_number
			t.string 			:telecom_name
			t.float 			:card_limit, 			:default => 0.0
			t.string 			:card_number
			t.boolean 		:is_active, 			:default => false
			t.text 				:description
      t.timestamps
    end
    add_index :asset_details, :company_id
  end
end
