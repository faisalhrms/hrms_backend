class CreateLeaveTransactionHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :leave_transaction_histories do |t|
    	t.integer 		:company_id
    	t.integer 		:employee_id
    	t.integer 		:leave_type_id
    	t.integer 		:leave_request_id
    	t.float 		:allocated_quota,    :default => 0.0
    	t.float 		:remaining_quota,    :default => 0.0
    	t.float 		:used_quota,         :default => 0.0
    	t.float 		:quota_transaction
    	t.string 		:transaction_type
    	t.text			:remarks
    	t.datetime		:transaction_date
        t.datetime      :leave_year_start_date
        t.datetime      :leave_year_end_date
      t.timestamps
    end
    add_index :leave_transaction_histories, :company_id
    add_index :leave_transaction_histories, :employee_id
    add_index :leave_transaction_histories, :leave_type_id
    add_index :leave_transaction_histories, :leave_request_id
  end
end
