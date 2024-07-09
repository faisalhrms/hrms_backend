class AddSalaryUnitIdInAttendanceCutoffs < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_cutoffs, :salary_unit_id, 		:integer
  	add_column :attendance_cutoffs, :salary_unit_wise, 	:boolean, :default => false
  end
end
