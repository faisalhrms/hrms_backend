class AddColumnsToTaskTable < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks,  :employee_id, :integer
    add_column  :tasks, :fiscal_year_id,  :integer
  end
end
