class AddApprovalColumnInObjectiveSetting < ActiveRecord::Migration[7.1]
  def change
    add_column  :objective_settings, :line_manager_approval,  :string, :default => "Pending"
  end
end
