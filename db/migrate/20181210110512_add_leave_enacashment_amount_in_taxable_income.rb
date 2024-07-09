class AddLeaveEnacashmentAmountInTaxableIncome < ActiveRecord::Migration[7.1]
  def change
  	remove_column :employee_taxable_incomes, :leave_enacashment_amount, :float
  	add_column 		:employee_taxable_incomes, :leave_encashment_amount, 	:float, :default => 0.0
  end
end
