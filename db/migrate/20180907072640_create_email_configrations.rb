class CreateEmailConfigrations < ActiveRecord::Migration[7.1]
  def change
    create_table :email_configrations do |t|
    	t.integer 		:company_id
    	t.string 			:name
    	t.string 			:user_name
    	t.string 			:email
    	t.string 			:password
    	t.string 			:outgoing_server_address
    	t.string 			:outgoing_server_port
    	t.string 			:domain
      t.boolean     :is_active, :default => true
      t.timestamps
    end
    add_index :email_configrations, :company_id
  end
end
