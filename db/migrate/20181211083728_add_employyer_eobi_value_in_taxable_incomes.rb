class AddEmployyerEobiValueInTaxableIncomes < ActiveRecord::Migration[7.1]
  def change
  	add_column 	:employee_taxable_incomes, :employeer_eobi_value, 	:float, 	:default => 0.0
  end
end
