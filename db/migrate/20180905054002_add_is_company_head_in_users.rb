class AddIsCompanyHeadInUsers < ActiveRecord::Migration[7.1]
  def change
  	add_column :users, :is_company_head, 		:boolean, :default => false
  	add_column :users, :is_location_head, 	:boolean, :default => false
  	add_column :users, :is_branch_head, 		:boolean, :default => false
  	add_column :users, :is_department_head, :boolean, :default => false
  end
end
