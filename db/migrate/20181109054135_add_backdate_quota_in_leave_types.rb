class AddBackdateQuotaInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_types, :backdate_quota, 						:boolean, 	:default => false
  end
end
