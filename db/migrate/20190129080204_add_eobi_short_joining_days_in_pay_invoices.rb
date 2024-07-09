class AddEobiShortJoiningDaysInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :eobi_short_joining_days, 			:float, :default => 0.0
		add_column :pay_invoices, :eobi_no_of_days_till_joining, 	:float, :default => 0.0
  end
end
