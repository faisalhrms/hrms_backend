class AddVehicleTaxValueInTaxableIncomes < ActiveRecord::Migration[7.1]
  def change
  	add_column 	:employee_taxable_incomes, :current_month_vehicle_tax, 	:float, 	:default => 0.0
		add_column 	:employee_taxable_incomes, :predicted_vehicle_tax, 			:float, 	:default => 0.0
  end
end