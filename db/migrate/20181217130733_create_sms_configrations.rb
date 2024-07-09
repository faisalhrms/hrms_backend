class CreateSmsConfigrations < ActiveRecord::Migration[7.1]
  def change
    create_table :sms_configrations do |t|
			t.integer 	:company_id
			t.string 		:name
			t.string 		:url
			t.string 		:user_name
			t.string 		:password
			t.string 		:show_password
			t.string 		:masking
			t.boolean 	:is_active, :default => false
      t.timestamps
    end
    add_index :sms_configrations, :company_id
  end
end
