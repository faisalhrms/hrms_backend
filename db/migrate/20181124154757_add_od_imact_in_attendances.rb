class AddOdImactInAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column 		:employee_attendances, :is_official_duty, 	:boolean, :default => false
  	add_column 		:employee_attendances, :is_relaxation, 			:boolean, :default => false
  end
end