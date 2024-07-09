class AddPayableGrossInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column 	:pay_invoices, :payable_gross, :float, :default => 0.0
  end
end
