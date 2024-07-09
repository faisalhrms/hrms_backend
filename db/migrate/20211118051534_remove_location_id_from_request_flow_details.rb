class RemoveLocationIdFromRequestFlowDetails < ActiveRecord::Migration[7.1]
  def change
    remove_column :request_flow_details, :location_id, :integer
  end
end
