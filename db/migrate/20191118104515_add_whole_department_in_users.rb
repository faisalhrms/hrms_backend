class AddWholeDepartmentInUsers < ActiveRecord::Migration[7.1]
  def change
  	add_column :users, :all_company_department, :boolean, :default => false
  end
end
