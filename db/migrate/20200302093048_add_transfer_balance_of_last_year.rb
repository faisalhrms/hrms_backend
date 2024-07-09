class AddTransferBalanceOfLastYear < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_types, :transfer_probation_balance, :boolean, :default => false
  end
end
