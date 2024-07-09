class AddColumnsTotalToComments < ActiveRecord::Migration[7.1]
  def change
    add_column  :appraisal_comments,  :total_emp_task_score,  :float
    add_column  :appraisal_comments,  :total_emp_competency_score,  :float
  end
end
