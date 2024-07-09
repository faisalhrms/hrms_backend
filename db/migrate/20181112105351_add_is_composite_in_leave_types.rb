class AddIsCompositeInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_requests, :is_composite, :boolean, :default => false
  end
end
