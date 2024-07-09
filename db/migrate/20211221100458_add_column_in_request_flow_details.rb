class AddColumnInRequestFlowDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :request_flow_details, :criteria, :float
    add_column :request_flows, :criteria, :float
  end
end
