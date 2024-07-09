class CreateRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :roles do |t|
    	t.string		:name
    	t.integer		:company_id
      t.timestamps
    end
    add_index :roles, :company_id
  end
end
