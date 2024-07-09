class AddAddressInformationInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees,	:current_address, 			:text
  	add_column :employees,	:current_country_id, 		:integer
  	add_column :employees,	:current_state_id, 			:integer
  	add_column :employees,	:current_city_id, 			:integer
  end
end
