class AddRequestOnDashboardInUsers < ActiveRecord::Migration[7.1]
  def change
  	add_column :users, :request_on_dashboard, :boolean, :default => false
  end
end
