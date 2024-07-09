class AddVehicleMonthlyProratedInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :vehicle_monthly_prorated, :boolean, :default => false
  end
end
