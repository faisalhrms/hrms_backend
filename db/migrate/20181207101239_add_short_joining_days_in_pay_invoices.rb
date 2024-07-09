class AddShortJoiningDaysInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :short_joining_days, :float, :default => 0.0
  end
end
