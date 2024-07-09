class AddAttendanceRestrictionInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
		add_column :leave_types, :attendance_restricted, 						:boolean, :default => false
		add_column :leave_types, :attendance_restricted_applicable, :string
		add_column :leave_types, :no_of_absent, 										:float, 	:default => 0.0
  end
end
