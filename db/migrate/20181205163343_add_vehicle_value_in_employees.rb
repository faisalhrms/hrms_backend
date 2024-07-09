class AddVehicleValueInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :vehicle_assignment_date, 	:datetime
		add_column :employees, :vehicle_value, 						:float, :default => 0.0
  end
end