class CreateSystemSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :system_settings do |t|
    	t.integer 	:company_id
    	t.string 		:name
    	t.string 		:employee_prefix_code_usage
      t.timestamps
    end
    add_index :system_settings, :company_id
  end
end
