class AddEncashableQuotaInEmployeeAttendance < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, 	:gross_salary, 			:float, :default => 0.0
  	add_column :employee_attendances, 	:encashable_quota, 	:float, :default => 0.0
  	add_column :finalize_attendances, 	:encashable_quota, 	:float, :default => 0.0

  	add_column :employees, 							:regular_quota_encashment,			:boolean, :default => false
  	add_column :employees, 							:holiday_quota_encashment,			:boolean, :default => false
  	add_column :benefit_structures, 		:regular_quota_encashment,			:boolean, :default => false
  	add_column :benefit_structures, 		:holiday_quota_encashment,			:boolean, :default => false
  	add_column :employee_attendances, 	:regular_quota_encashment,			:boolean, :default => false
  	add_column :employee_attendances, 	:holiday_quota_encashment,			:boolean, :default => false
  end
end
