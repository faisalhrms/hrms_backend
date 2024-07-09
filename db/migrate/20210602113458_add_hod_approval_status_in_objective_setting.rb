class AddHodApprovalStatusInObjectiveSetting < ActiveRecord::Migration[7.1]
  def change
    add_column  :objective_settings,  :hod_approval_status, :string,  :default => "Pending"
  end
end
