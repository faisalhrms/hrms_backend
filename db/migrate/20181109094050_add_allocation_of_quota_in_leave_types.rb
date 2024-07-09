class AddAllocationOfQuotaInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_types, :allocation_of_quota, :string
  end
end