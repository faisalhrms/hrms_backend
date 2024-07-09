class CreateHolidays < ActiveRecord::Migration[7.1]
  def change
    create_table :holidays do |t|
    	t.integer  		:company_id
    	t.string 			:name
    	t.string 			:code
    	t.text 				:description
    	t.datetime		:start_date
    	t.datetime		:end_date
    	t.boolean     :is_active, :default => true
      t.timestamps
    end
    add_index :holidays, 		:company_id
  end
end
