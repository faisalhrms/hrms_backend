class AddEndOfEmployementInTransactions < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :hold_salary, 	:boolean, :default => false
  	add_column :employee_transaction_histories, :left_type, 		:string
  	add_column :employee_transaction_histories, :left_reason, 	:text
  	
  	add_column :employees, 											:hold_salary, 	:boolean, :default => false
  	add_column :employees, 											:left_type, 		:string
  	add_column :employees, 											:left_reason, 	:text
  end
end
