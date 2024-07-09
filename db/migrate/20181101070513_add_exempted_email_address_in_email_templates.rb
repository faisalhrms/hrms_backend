class AddExemptedEmailAddressInEmailTemplates < ActiveRecord::Migration[7.1]
  def change
  	add_column :email_templates, :is_exempted, 			:boolean, :default => false
		add_column :email_templates, :exempted_address, :text, 		:default => ""
  end
end
