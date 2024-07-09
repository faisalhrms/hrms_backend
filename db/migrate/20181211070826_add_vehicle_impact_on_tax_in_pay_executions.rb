class AddVehicleImpactOnTaxInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column 		:pay_executions, :vehicle_impact_on_tax, 		:boolean, :default => false
  	add_column 		:pay_executions, :vehicle_tax_percentage, 	:float, 	:default => 0.0
  	remove_column :pay_invoices, 	 :vehicle_short_days, 			:float
  end
end
