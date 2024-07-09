class AddMinuteDeductedAndEarnedInAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, :minute_deducted, :float, :default => 0.0
  	add_column :employee_attendances, :minute_earned, 	:float, :default => 0.0
  end
end
