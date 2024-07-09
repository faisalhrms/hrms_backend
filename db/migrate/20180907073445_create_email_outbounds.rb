class CreateEmailOutbounds < ActiveRecord::Migration[7.1]
  def change
	create_table :email_outbounds do |t|
		t.integer  		:company_id
		t.integer  		:email_configration_id
		t.integer  		:email_template_id
		t.string   		:from_address,   	default: ""
		t.string   		:to_address,   		default: ""
		t.string   		:cc_address,   		default: ""
		t.string   		:subject
		t.string 		  :server_user_name
		t.string 		  :server_email
		t.string 		  :server_password
		t.string 		  :server_address
		t.string 		  :server_port
		t.string 		  :server_domain
		t.boolean  		:is_cc,        		default: false
		t.text     		:message
	  t.timestamps
	end
	add_index :email_outbounds, 		:company_id
	add_index :email_outbounds, 		:email_configration_id
	add_index :email_outbounds, 		:email_template_id
  end
end
