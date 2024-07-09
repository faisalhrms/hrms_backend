class CreateRequestFlowDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :request_flow_details do |t|
    	t.integer 	:request_flow_id
    	t.integer 	:department_id
    	t.integer 	:employee_id
    	t.string 		:request_node
    	t.boolean 	:specific_condition, :default => false
      t.timestamps
    end
    add_index :request_flow_details, :request_flow_id
    add_index :request_flow_details, :department_id
    add_index :request_flow_details, :employee_id
  end
end
