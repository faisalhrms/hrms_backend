class AddShortConfirmationDaysInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, 	:short_confirmation_days, :float, 	:default => 0.0
  	add_column :pay_invoices, 	:vehicle_short_days, 			:float, 	:default => 0.0
  	add_column :pay_invoices, 	:vehicle_months, 					:float, 	:default => 0.0
  	add_column :pay_executions, :is_locked, 							:boolean, :default => false
  end
end
