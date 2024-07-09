class AddCloumnRequestFlows < ActiveRecord::Migration[7.1]
  def change
    add_column :request_flows, :back_date_limit, :float , default: 0.0
    add_column :request_flows, :back_date_apply, :boolean , default: false
  end
end
