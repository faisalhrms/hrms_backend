class AddOtherCustomizeTaxWorkingInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_taxable_incomes, :employer_yearly_contribution, 							:float, 	:default => 0.0
  	add_column :employee_taxable_incomes, :employer_contribution_before_tax_on_tax, 	:float, 	:default => 0.0
  	add_column :employee_taxable_incomes, :tax_on_tax, 																:float, 	:default => 0.0
  	add_column :employee_taxable_incomes, :total_tax_on_tax, 													:float, 	:default => 0.0
  end
end
