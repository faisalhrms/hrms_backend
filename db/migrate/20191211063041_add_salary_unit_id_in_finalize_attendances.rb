class AddSalaryUnitIdInFinalizeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :finalize_attendances, :salary_unit_id, 		:integer
  end
end
