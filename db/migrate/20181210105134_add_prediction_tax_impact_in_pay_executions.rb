class AddPredictionTaxImpactInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :prediction_tax_impact, :boolean, :default => false
  end
end
