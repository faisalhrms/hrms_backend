class AddRosterEmployeeIdInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :roster_employee_id, :integer
  end
end
