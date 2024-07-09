class CreateRolePermissions < ActiveRecord::Migration[7.1]
  def change
    create_table :role_permissions do |t|
    	t.string 		:display_name
    	t.string 		:module_name
    	t.boolean		:index_access,			:default => false
    	t.boolean		:create_access,			:default => false
    	t.boolean		:view_access,				:default => false
    	t.boolean		:update_access,			:default => false
    	t.boolean		:delete_access,			:default => false
      t.timestamps
    end
  end
end
