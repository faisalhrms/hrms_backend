class AddPrevFinalizeInAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, :prev_finalized, :boolean, :default => false
  end
end
