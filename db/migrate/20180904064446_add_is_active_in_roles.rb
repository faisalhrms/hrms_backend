class AddIsActiveInRoles < ActiveRecord::Migration[7.1]
  def change
  	add_column :roles, :is_active, :boolean, :default => true
  end
end
