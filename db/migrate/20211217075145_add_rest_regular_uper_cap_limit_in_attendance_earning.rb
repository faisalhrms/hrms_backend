class AddRestRegularUperCapLimitInAttendanceEarning < ActiveRecord::Migration[7.1]
  def change
    add_column  :attendance_earnings, :rest_upper_cap,  :boolean, :default => false
    add_column  :attendance_earnings, :regular_upper_cap,  :boolean, :default => false
    add_column  :attendance_earnings, :rest_upper_cap_limit,  :float, :default => 0.0
    add_column  :attendance_earnings, :regular_upper_cap_limit,  :float, :default => 0.0
  end
end
