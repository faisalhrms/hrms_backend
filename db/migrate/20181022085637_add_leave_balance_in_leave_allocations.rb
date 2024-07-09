class AddLeaveBalanceInLeaveAllocations < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_allocations, :allocated_quota, 				:float, :default => 0.0
  	add_column :leave_allocations, :remaining_quota, 				:float, :default => 0.0
  	add_column :leave_allocations, :used_quota, 						:float, :default => 0.0
		add_column :leave_allocations, :leave_year_id, 					:integer
		add_column :leave_allocations, :leave_year_start_date, 	:datetime
		add_column :leave_allocations, :leave_year_end_date, 		:datetime
		add_column :leave_allocations, :is_active, 							:boolean, :default => false
  end
end
