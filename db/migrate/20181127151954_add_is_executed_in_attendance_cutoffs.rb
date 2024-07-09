class AddIsExecutedInAttendanceCutoffs < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_cutoffs, :is_executed, :boolean, :default => false
  end
end
