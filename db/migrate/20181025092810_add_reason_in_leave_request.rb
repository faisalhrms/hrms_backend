class AddReasonInLeaveRequest < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_requests, :reason, :text
  end
end
