class AddSalaryUnitWiseInAttendanceExceptions < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_exceptions, :salary_unit_id, 	:integer
  	add_column :attendance_exceptions, :salary_unit_wise, :boolean, :default => false
  end
end
