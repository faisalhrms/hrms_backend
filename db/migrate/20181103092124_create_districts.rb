class CreateDistricts < ActiveRecord::Migration[7.1]
  def change
    create_table :districts do |t|
    	t.integer 	:division_id
    	t.integer 	:country_id
    	t.integer 	:state_id
    	t.string 		:name
      t.timestamps
    end
    add_index :districts, :division_id
    add_index :districts, :country_id
    add_index :districts, :state_id
  end
end
