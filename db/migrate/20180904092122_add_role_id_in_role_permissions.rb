class AddRoleIdInRolePermissions < ActiveRecord::Migration[7.1]
  def change
  	add_column :role_permissions, 		:role_id, 	:integer
  end
end
