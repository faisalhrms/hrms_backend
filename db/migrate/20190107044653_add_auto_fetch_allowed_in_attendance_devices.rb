class AddAutoFetchAllowedInAttendanceDevices < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_devices, :auto_fetch_allowed, :boolean, :default => false
  end
end
