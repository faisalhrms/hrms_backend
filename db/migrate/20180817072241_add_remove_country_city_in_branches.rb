class AddRemoveCountryCityInBranches < ActiveRecord::Migration[7.1]
  def change
  	remove_column :branches, 	:country_id, 	:string
		remove_column :branches, 	:state_id, 		:string
		remove_column :branches, 	:city_id, 		:string

  	add_column :branches, 		:country_id, 	:integer
		add_column :branches, 		:state_id, 		:integer
		add_column :branches, 		:city_id, 		:integer
  end
end
