class AddIsHolidayOvertimeInEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :is_regular_cpl, 			:boolean, :default => false
  	add_column :employees, :is_holiday_overtime, 	:boolean, :default => false

  	add_column :benefit_structures, :is_regular_cpl, 			:boolean, :default => false
  	add_column :benefit_structures, :is_holiday_overtime, 	:boolean, :default => false

  	add_column :employee_attendances, :is_regular_cpl, 			:boolean, :default => false
  	add_column :employee_attendances, :is_holiday_overtime, 	:boolean, :default => false
  end
end
