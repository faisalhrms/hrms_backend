class AddAddionalMinutesInAttendanceStructures < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_structures, :addional_minutes, :float, :default => 0.0 
  end
end
