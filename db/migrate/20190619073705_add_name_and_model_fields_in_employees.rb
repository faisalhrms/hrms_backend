class AddNameAndModelFieldsInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :vehicle_name, 					:string
  	add_column :employees, :vehicle_model, 					:string
  	add_column :employees, :laptop_name, 						:string
  	add_column :employees, :laptop_model, 					:string
  	add_column :employees, :cell_phone_name, 				:string
  	add_column :employees, :cell_phone_model, 			:string
  	add_column :employees, :laptop_assignment_date, :datetime
  	add_column :employees, :cell_assignment_date, 	:datetime
  end
end
