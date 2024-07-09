class AddIncentiveVerifiedInAttendances < ActiveRecord::Migration[7.1]
  def change
  	remove_column :employee_attendances, :attendance_exemption, 	:boolean

  	add_column 		:employee_attendances, :incentive_verified, 		:boolean, :default => false
  end
end
