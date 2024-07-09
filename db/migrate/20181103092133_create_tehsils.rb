class CreateTehsils < ActiveRecord::Migration[7.1]
  def change
    create_table :tehsils do |t|
    	t.integer 	:division_id
    	t.integer 	:district_id
    	t.integer 	:country_id
    	t.integer 	:state_id
    	t.string 		:name
      t.timestamps
    end
    add_index :tehsils, :division_id
    add_index :tehsils, :district_id
    add_index :tehsils, :country_id
    add_index :tehsils, :state_id
  end
end
