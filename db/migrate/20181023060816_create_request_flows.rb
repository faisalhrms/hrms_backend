class CreateRequestFlows < ActiveRecord::Migration[7.1]
  def change
    create_table :request_flows do |t|
    	t.integer 	:company_id
    	t.string 		:name
    	t.string 		:request_flow_type
    	t.string 		:request_node
      t.timestamps
    end
    add_index :request_flows, :company_id
  end
end
