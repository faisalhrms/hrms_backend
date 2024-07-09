class AddLeaveAllocationIdInLeaveTransactionHistories < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_transaction_histories, :leave_allocation_id, :integer
  end
end
