class AddIsContractualInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :is_contractual, 			:boolean, :default => false
  	add_column :employees, :contract_start_date, 	:datetime
  	add_column :employees, :contract_end_date, 		:datetime
  end
end
