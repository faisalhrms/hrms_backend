class AddPfTaxValueInTaxableIncomes < ActiveRecord::Migration[7.1]
  def change
  	add_column 	:employee_taxable_incomes, :employeer_pf_value, 	:float, 	:default => 0.0
		add_column 	:employee_taxable_incomes, :predicted_pf_value, 	:float, 	:default => 0.0
		add_column 	:employee_taxable_incomes, :pf_tax_value, 				:float, 	:default => 0.0
  end
end
