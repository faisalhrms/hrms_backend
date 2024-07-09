class CreateFuelCardDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :fuel_card_details do |t|
    	t.integer 	:employee_id
    	t.integer 	:company_id
    	t.string 		:card_no
			t.string 		:card_name
			t.string 		:registration
			t.float 		:fleet_division, 			:default => 0.0
			t.float 		:quantity_consumed, 	:default => 0.0
			t.float 		:amount_consumed, 		:default => 0.0
			t.float 		:last_km, 						:default => 0.0
			t.float 		:consumption, 				:default => 0.0
      t.timestamps
    end
  end
end
