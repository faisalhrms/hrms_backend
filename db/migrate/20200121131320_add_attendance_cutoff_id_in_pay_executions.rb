class AddAttendanceCutoffIdInPayExecutions < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :attendance_cutoff_ids, :text
  end
end
