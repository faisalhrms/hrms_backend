class AddPerLitreRateInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :per_litre_rate, :float, :default => 0.0
  end
end
