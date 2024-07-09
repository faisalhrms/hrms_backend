class AddAttendanceExemptedInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :is_overtime, 					:boolean, :default => false
  	add_column :employees, :is_off_day_working, 	:boolean, :default => false
  	add_column :employees, :is_cpl, 							:boolean, :default => false
  	add_column :employees, :attendance_exempted, 	:boolean, :default => false
  end
end
