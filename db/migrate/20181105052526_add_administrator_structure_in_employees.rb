class AddAdministratorStructureInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :current_division_id, 	:integer
		add_column :employees, :current_district_id, 	:integer
		add_column :employees, :current_tehsil_id, 		:integer
  end
end
