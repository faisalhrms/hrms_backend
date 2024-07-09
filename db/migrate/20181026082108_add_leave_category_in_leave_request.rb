class AddLeaveCategoryInLeaveRequest < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_requests, :leave_category, :string, :default => "Full Day"
  end
end
