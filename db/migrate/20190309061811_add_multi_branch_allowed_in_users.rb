class AddMultiBranchAllowedInUsers < ActiveRecord::Migration[7.1]
  def change
  	add_column :users, :multi_branch_allowed, :boolean, :default => false
  	add_column :users, :branch_ids, 					:text, :default => ""
  end
end
