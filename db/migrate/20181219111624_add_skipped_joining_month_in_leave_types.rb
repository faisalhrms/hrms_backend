class AddSkippedJoiningMonthInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_types, :skipped_joining_month, :boolean, :default => false
  end
end
