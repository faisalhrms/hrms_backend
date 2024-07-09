class AddIndexFromRequestFlowDetails < ActiveRecord::Migration[7.1]
  def change
    add_index :request_flow_details, :branch_id
  end
end
