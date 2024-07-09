class AddExtraPayDaysInPayExecution < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, 	:extra_pay_days, 			:float, 	:default => 0.0
  	add_column :pay_invoices, 	:allowed_extra_days, 	:boolean, :default => false
  	add_column :pay_executions, :allowed_extra_days, 	:boolean, :default => false
  end
end
