class CreateLeaveRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :leave_requests do |t|
    	t.integer			:company_id
    	t.integer			:employee_id
    	t.integer			:leave_type_id
    	t.float 			:allocated_quota, 	:default => 0.0
			t.float 			:used_quota, 				:default => 0.0
			t.float 			:remaining_quota, 	:default => 0.0
			t.float 			:request_count, 		:default => 0.0
			t.float 			:sandwich_count, 		:default => 0.0
			t.datetime 		:min_apply_date
			t.datetime 		:start_date
			t.datetime 		:end_date
      t.string      :request_status
      t.string      :apply_status
      t.boolean     :is_cancelled,      :default => false
      t.timestamps
    end
    add_index :leave_requests, :company_id
    add_index :leave_requests, :employee_id
    add_index :leave_requests, :leave_type_id
  end
end
