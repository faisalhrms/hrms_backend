class AddFieldsInRequestFlow < ActiveRecord::Migration[7.1]
  def change
    add_column :request_flow_details, :location_id, :integer
    add_column :request_flow_details, :branch_id, :integer
  end
end
