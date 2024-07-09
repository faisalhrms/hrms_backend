class CreateSmsTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :sms_templates do |t|
			t.integer 		:company_id
			t.integer 		:sms_configration_id
			t.string 			:name
			t.boolean 		:is_active, 				:default => false
			t.boolean 		:is_exempted, 			:default => false
			t.string 			:exempted_numbers
			t.string 			:trigger
			t.text 				:message
      t.timestamps
    end
    add_index :sms_templates, :company_id
    add_index :sms_templates, :sms_configration_id
  end
end
