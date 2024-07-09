class AddEarnedQuotaInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_types, :quota_allocation, :boolean, :default => false
  	add_column :leave_types, :earned_quota, 		:boolean, :default => false
  end
end
