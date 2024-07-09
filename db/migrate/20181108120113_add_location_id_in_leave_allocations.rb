class AddLocationIdInLeaveAllocations < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_allocations, :location_id, :integer
  end
end
