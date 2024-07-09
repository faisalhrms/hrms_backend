class CreateEmailExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :email_executions do |t|
    	t.integer 	:company_id
			t.integer 	:location_id
			t.integer 	:branch_id
			t.integer 	:grade_id
			t.string 		:name
			t.integer 	:email_template_id
			t.string 		:trigger
      t.timestamps
    end
    add_index :email_executions, :company_id
		add_index :email_executions, :location_id
		add_index :email_executions, :branch_id
		add_index :email_executions, :grade_id
		add_index :email_executions, :email_template_id
  end
end
