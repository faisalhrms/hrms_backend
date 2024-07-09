class CreateLeaveRequestDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :leave_request_details do |t|
    	t.integer 	:leave_request_id
    	t.integer 	:leave_type_id
    	t.float 		:allocated_quota, :default => 0.0
    	t.float 		:used_quota, 			:default => 0.0
    	t.float 		:remaining_quota, :default => 0.0
      t.timestamps
    end
  end
end
