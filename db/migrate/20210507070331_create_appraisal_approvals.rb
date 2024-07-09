class CreateAppraisalApprovals < ActiveRecord::Migration[7.1]
  def change
    create_table :appraisal_approvals do |t|
      t.integer :objective_id
      t.integer :employee_id
      t.float   :net_score

      t.timestamps
    end
  end
end
