class AddColumnToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column  :tasks, :weighted_score,  :float
  end
end
