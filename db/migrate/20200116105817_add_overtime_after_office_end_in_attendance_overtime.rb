class AddOvertimeAfterOfficeEndInAttendanceOvertime < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_overtimes, :overtime_after_office_end, :boolean, :default => false
  end
end
