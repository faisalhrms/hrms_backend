class AddFieldsInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_types, :location_id, 								:integer
  	add_column :leave_types, :auto_allocation, 						:boolean, 	:default => false
		add_column :leave_types, :special_leave, 							:boolean, 	:default => false
		add_column :leave_types, :earned_quota_max_limit, 		:float, 		:default => 0.0
		add_column :leave_types, :frequency, 									:string, 		:default => ""
		add_column :leave_types, :no_of_years, 								:string, 		:default => ""
  end
end
