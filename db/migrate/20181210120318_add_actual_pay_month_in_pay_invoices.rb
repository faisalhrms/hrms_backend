class AddActualPayMonthInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :actual_pay_month, :datetime
  end
end
