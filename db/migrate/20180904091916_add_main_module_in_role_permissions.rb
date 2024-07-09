class AddMainModuleInRolePermissions < ActiveRecord::Migration[7.1]
  def change
  	add_column :role_permissions, 		:main_module, 	:string
  end
end
