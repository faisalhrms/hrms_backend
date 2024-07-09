class AddAutoAttendanceFetchingInSystemSetting < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :auto_attendance_fetching, :boolean, :default => false
  	add_column :system_settings, :auto_attendance_process, 	:boolean, :default => false
  	add_column :system_settings, :schedule_time, 						:text, 		:default => ""
  	add_column :system_settings, :attendance_days, 					:float, 	:default => 0.0
  end
end

