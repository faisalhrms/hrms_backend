class AddUpperCapInAttendanceEarnings < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_earnings, :upper_cap, 				:boolean, :default => false
		add_column :attendance_earnings, :upper_cap_limit, 	:float, 	:default => 0.0
  end
end
