class AddCoulmnsToEmployeeTaxableIncomes < ActiveRecord::Migration[7.1]
  def change
    add_column :employee_taxable_incomes, :cpr_date,  :datetime
    add_column :employee_taxable_incomes, :cpr_number, :string
  end
end
