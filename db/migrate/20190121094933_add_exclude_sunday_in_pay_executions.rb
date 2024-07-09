class AddExcludeSundayInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :exclude_sunday, :boolean, :default => false
  end
end
