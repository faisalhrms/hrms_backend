class AddJoiningExceptionPayDaysInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :joining_exception_pay_days, 				:float, :default => 0.0
  	add_column :pay_executions, :joining_exception_formated_month, 	:string
  	add_column :pay_executions, :joining_exception_month, 					:datetime
  	add_column :pay_executions, :joining_exception, 								:boolean, :default => false
  end
end
