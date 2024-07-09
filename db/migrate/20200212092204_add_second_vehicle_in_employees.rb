class AddSecondVehicleInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :velicle_two_allowed, 					:boolean, 	:default => false
		add_column :employees, :velicle_two_eligibility, 			:string, 		:default => "Date of Joining"
		add_column :employees, :velicle_two_other_date, 			:datetime
		add_column :employees, :vehicle_two_assignment_date, 	:datetime
		add_column :employees, :vehicle_two_name, 						:string, 		:default => ""
		add_column :employees, :vehicle_two_model, 						:string, 		:default => ""
		add_column :employees, :vehicle_two_value, 						:float, 		:default => 0.0
  end
end
