class AddNoOfDaysTillJoiningInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :no_of_days_till_joining, :float, :default => 0.0
  end
end
