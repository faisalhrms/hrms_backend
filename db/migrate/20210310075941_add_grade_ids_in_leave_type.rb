class AddGradeIdsInLeaveType < ActiveRecord::Migration[7.1]
  def change
    add_column :leave_types, :grade_ids, :string
  end
end
