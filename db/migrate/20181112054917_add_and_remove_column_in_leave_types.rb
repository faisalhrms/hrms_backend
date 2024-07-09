class AddAndRemoveColumnInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
  	remove_column :leave_types, :allocation_of_quota, 	:string
  	remove_column :leave_types, :frequency, 						:string
  end
end
