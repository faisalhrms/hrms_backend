class AddQuotaTransactionInLeaveRequestDetails < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_request_details, :quota_transaction, :float, :default => 0.0
  end
end
