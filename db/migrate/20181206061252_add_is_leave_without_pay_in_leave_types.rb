class AddIsLeaveWithoutPayInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_types, :is_leave_without_pay, :boolean, :default => false
  end
end
