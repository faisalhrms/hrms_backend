class AddIsCompositeInLeaveRequest < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_types, :is_composite, :boolean, :default => false
  end
end
