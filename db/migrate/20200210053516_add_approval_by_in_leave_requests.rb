class AddApprovalByInLeaveRequests < ActiveRecord::Migration[7.1]
  def change
  	add_column :official_duties, 			:approval_name, :string, :default => "-"
  	add_column :leave_requests, 			:approval_name, :string, :default => "-"
  	add_column :relaxation_requests, 	:approval_name, :string, :default => "-"
  	
  	add_column :official_duties, 			:approval_datetime, :datetime
  	add_column :leave_requests, 			:approval_datetime, :datetime
  	add_column :relaxation_requests, 	:approval_datetime, :datetime
  end
end
