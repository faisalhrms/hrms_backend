class AddColumnToTaskEmployeeRating < ActiveRecord::Migration[7.1]
  def change
    add_column  :tasks, :employee_rating, :integer
  end
end
