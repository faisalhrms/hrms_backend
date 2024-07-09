class AddStartDateInTasks < ActiveRecord::Migration[7.1]
  def change
    add_column  :tasks, :start_date,  :date
  end
end
