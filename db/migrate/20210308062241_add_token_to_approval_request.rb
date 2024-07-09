class AddTokenToApprovalRequest < ActiveRecord::Migration[7.1]
  def change
    add_column :approval_requests, :token, :string
  end
end
