class AddIsGeneratedInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :is_generated, :boolean, :default => false
  end
end
