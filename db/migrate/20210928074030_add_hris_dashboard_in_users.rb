class AddHrisDashboardInUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :hris_dashboard, :boolean, :default => false
  end
end