class AddTotalWorkingMinutesInAttendanceStructures < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_structures, :total_working_minutes, :float, :default => 0.0
  end
end
