class AddIsHodApprovedInApprovalRequest < ActiveRecord::Migration[7.1]
  def change
    add_column  :approval_requests, :is_hod_approved,  :boolean,  default: false
    add_column  :approval_requests, :is_hod_submitted,  :boolean,  default: false
  end
end
