class AddFieldsInAddressInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, 					:permanent_country_id, 				:integer
    add_column :employees, 					:permanent_state_id, 				:integer
    add_column :employees, 					:permanent_city_id, 				:integer
  end
end
