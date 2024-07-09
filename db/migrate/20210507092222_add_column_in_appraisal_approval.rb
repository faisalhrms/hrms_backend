class AddColumnInAppraisalApproval < ActiveRecord::Migration[7.1]
  def change
    add_column  :appraisal_approvals, :status,  :string
    add_column  :appraisal_approvals, :comments,  :string
  end
end
