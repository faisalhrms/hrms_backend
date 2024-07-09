class AddRoleIdInUsers < ActiveRecord::Migration[7.1]
  def change
  	add_column :users, :role_id, :integer
  end
end
