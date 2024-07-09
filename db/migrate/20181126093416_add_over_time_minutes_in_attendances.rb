class AddOverTimeMinutesInAttendances < ActiveRecord::Migration[7.1]
  def change
  	remove_column :employee_attendances, :remaining_working_hour, :float

  	add_column 		:employee_attendances, :over_time_minutes, 			:float, :default => 0.0
  end
end

