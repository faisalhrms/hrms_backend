class AddDeviceIdInAttendanceMachineLogs < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_machine_logs, :device_id, :string, :default => ""
  end
end
