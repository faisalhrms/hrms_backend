class AddCustomizeTaxWorkingInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :customize_tax, 	:boolean, :default => false
		add_column :pay_invoices, :tax_criteria, 		:string, 	:default => ""
		add_column :pay_invoices, :fixed_tax_rate, 	:float, 	:default => 0.0
  end
end
