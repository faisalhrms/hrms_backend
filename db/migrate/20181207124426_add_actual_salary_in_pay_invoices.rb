class AddActualSalaryInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column 	:pay_invoices, :actual_salary, :float, :default => 0.0
  end
end
