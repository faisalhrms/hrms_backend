class AddLimitOnProbationInLeavePolicy < ActiveRecord::Migration[7.1]
  def change
		add_column :leave_types, :probation_limit_request_in_tenure, 	:boolean, :default => false
		add_column :leave_types, :probation_limit_request_tenure, 		:string, 	:default => "Monthly"
		add_column :leave_types, :probation_limit_request_count, 			:float, 	:default => 0.0
  end
end
