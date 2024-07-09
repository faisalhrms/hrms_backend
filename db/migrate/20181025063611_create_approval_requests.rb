class CreateApprovalRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :approval_requests do |t|
    	t.integer		:company_id
    	t.integer		:request_sender_id
    	t.integer		:request_receiver_id
    	t.integer		:request_flow_id
    	t.string 		:approval_request_status
    	t.boolean		:is_approved, 	:default => false
    	t.references 	:requestable, 	polymorphic: true
      t.timestamps
    end
    add_index :approval_requests, :company_id
    add_index :approval_requests, :request_flow_id
    add_index :approval_requests, :request_sender_id
    add_index :approval_requests, :request_receiver_id
  end
end
