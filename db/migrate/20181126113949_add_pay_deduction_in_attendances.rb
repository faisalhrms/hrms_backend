class AddPayDeductionInAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column 		:employee_attendances, :pay_deduction, :float, :default => 0.0
  end
end
