class RemoveColumnFromAppraisals < ActiveRecord::Migration[7.1]
  def change
    remove_column :appraisals,  :objective_id
    remove_column :appraisals,  :task_id
    add_column  :appraisals,  :employee_rating, :string
    add_column  :appraisals,  :fiscal_year_id,  :integer
  end
end
