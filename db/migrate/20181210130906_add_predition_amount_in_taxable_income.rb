class AddPreditionAmountInTaxableIncome < ActiveRecord::Migration[7.1]
  def change
  	add_column 	:employee_taxable_incomes, :predition_amount, 				:float, :default => 0.0
		add_column 	:employee_taxable_incomes, :predition_item_amounts, 	:text, 	:default => ""
		add_column 	:employee_taxable_incomes, :predition_item_ids, 			:text, 	:default => ""
		add_column 	:employee_taxable_incomes, :predition_item_names, 		:text, 	:default => ""
  end
end
