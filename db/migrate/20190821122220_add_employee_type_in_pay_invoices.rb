class AddEmployeeTypeInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :employee_type_id, :integer
  end
end
