class AddConfimrationDueDateInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :confimration_due_date, :datetime
  end
end
