class AddNameInUrduInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :allowed_urdu, :boolean, :default => false
  end
end
