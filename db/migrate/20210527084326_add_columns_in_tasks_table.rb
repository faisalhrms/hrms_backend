class AddColumnsInTasksTable < ActiveRecord::Migration[7.1]
  def change
    add_column  :tasks, :line_manager_rating, :integer
    add_column  :tasks, :line_manager_weighted_score, :float
  end
end
