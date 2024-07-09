class AddPrevVehicleTaxInTaxableIncomes < ActiveRecord::Migration[7.1]
  def change
  	add_column 	:employee_taxable_incomes, :prev_vehicle_tax, 	:float, 	:default => 0.0
  end
end
