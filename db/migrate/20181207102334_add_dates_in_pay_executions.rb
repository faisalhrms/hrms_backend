class AddDatesInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :start_date, 	:datetime
		add_column :pay_executions, :end_date, 		:datetime
  end
end
