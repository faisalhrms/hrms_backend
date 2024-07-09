class AddWorkingDaysInAttendanceEarning < ActiveRecord::Migration[7.1]
  def change
    add_column  :attendance_earnings, :working_days,  :string
  end
end
