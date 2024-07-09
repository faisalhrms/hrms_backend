class AddCheckoutDeductionInAttendances < ActiveRecord::Migration[7.1]
  def change
  	remove_column :employee_attendances, :salary_deduction, 			:float
  	remove_column :employee_attendances, :early_left_deduction, 	:float

  	add_column 		:employee_attendances, :checkout_deduction,				:float, 	:default => 0.0
  	add_column 		:employee_attendances, :deduction_from_quota, 		:boolean, :default => false
  	add_column 		:employee_attendances, :deduction_from_salary, 		:boolean, :default => false
  end
end
