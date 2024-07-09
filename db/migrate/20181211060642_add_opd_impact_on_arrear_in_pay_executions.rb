class AddOpdImpactOnArrearInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :opd_impact_on_arrear, 	:boolean, :default => false
  end
end
