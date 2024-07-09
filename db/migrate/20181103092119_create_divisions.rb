class CreateDivisions < ActiveRecord::Migration[7.1]
  def change
    create_table :divisions do |t|
    	t.integer 	:country_id
    	t.integer 	:state_id
    	t.string 		:name
      t.timestamps
    end
    add_index :divisions, :country_id
    add_index :divisions, :state_id
  end
end
