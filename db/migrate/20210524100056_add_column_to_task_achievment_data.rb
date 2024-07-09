class AddColumnToTaskAchievmentData < ActiveRecord::Migration[7.1]
  def change
    add_column  :tasks, :achievement_date, :string
  end
end
