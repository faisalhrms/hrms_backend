class AdColumnsInAppraisalTable < ActiveRecord::Migration[7.1]
  def change
    add_column  :appraisals,  :line_manager_rating, :string
    add_column  :appraisal_comments,  :line_manager_comments, :string
    add_column  :appraisal_comments,  :total_line_manager_task_score, :float
    add_column  :appraisal_comments, :total_line_manager_competency_score, :float
  end
end
