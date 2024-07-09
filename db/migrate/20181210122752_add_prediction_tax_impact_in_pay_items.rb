class AddPredictionTaxImpactInPayItems < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_items, :prediction_tax_impact, 	:boolean, :default => false
  end
end
