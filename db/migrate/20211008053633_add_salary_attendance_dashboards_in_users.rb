class AddSalaryAttendanceDashboardsInUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :salary_dashboard, :boolean, :default => false
    add_column :users, :attendance_dashboard, :boolean, :default => false
  end
end
