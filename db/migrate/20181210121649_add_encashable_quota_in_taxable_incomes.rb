class AddEncashableQuotaInTaxableIncomes < ActiveRecord::Migration[7.1]
  def change
  	add_column 		:employee_taxable_incomes, :encashable_quota, 	:float, :default => 0.0
  end
end
