class AddColumnsInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :remaining_tax_year_month, 	:float, :default => 0.0
  	add_column :pay_invoices, :monthly_tax, 							:float, :default => 0.0
  	add_column :pay_invoices, :total_pf_months, 					:float, :default => 0.0

  	add_column :pay_executions, :incentive_impact_on_tax, 	:boolean, :default => false
  	add_column :pay_executions, :incentive_month, 					:datetime
  end
end
