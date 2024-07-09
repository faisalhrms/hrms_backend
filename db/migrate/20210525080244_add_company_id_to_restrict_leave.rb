class AddCompanyIdToRestrictLeave < ActiveRecord::Migration[7.1]
  def change
    add_column :restrict_leaves, :company_id, :integer
  end
end
