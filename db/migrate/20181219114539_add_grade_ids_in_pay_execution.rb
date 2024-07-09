class AddGradeIdsInPayExecution < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_executions, :grade_ids, :text
  end
end
