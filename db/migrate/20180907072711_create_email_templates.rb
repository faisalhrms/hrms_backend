class CreateEmailTemplates < ActiveRecord::Migration[7.1]
	def change
		create_table :email_templates do |t|
			t.integer 		:company_id
			t.integer 		:email_configration_id
			t.string 			:name
			t.string 			:subject
			t.string 			:trigger
			t.string 			:cc_address
			t.boolean 		:is_cc, :default => false
			t.text 				:message
			t.boolean			:is_active, :default => true
			t.timestamps
		end
		add_index :email_templates, :company_id
		add_index :email_templates, :email_configration_id
	end
end
