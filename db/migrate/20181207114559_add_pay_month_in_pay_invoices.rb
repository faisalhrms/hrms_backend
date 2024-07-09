class AddPayMonthInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column 	:pay_invoices, :pay_month, :string
  end
end
