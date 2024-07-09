class AddMultiplexAllowedInAttendanceEarnings < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_earnings, :multiplex_allowed, 	:boolean, :default => false
  	add_column :attendance_earnings, :holiday_ids, 				:text
  end
end
