class RemoveLeaveEncashmentAmountInTaxableIncome < ActiveRecord::Migration[7.1]
  def change
  	remove_column	:employee_taxable_incomes, :leave_encashment_amount, 	:float
  end
end
