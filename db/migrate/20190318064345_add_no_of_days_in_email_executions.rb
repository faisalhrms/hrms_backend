class AddNoOfDaysInEmailExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :email_executions, :no_of_days, :float, :default => 0.0
  end
end
