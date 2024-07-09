class CreateSmsExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :sms_executions do |t|
			t.integer 	:company_id
			t.integer 	:location_id
			t.integer 	:branch_id
			t.integer 	:grade_id
			t.string 		:name
			t.integer 	:sms_template_id
			t.string 		:trigger
      t.timestamps
    end
    add_index :sms_executions, :company_id
		add_index :sms_executions, :location_id
		add_index :sms_executions, :branch_id
		add_index :sms_executions, :grade_id
		add_index :sms_executions, :sms_template_id
  end
end
