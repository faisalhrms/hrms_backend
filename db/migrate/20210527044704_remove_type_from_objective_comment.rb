class RemoveTypeFromObjectiveComment < ActiveRecord::Migration[7.1]
  def change
    remove_column :objective_comments, :type
    remove_column :objective_comments, :employee_comments
    remove_column :objective_comments, :functional
    remove_column :objective_comments, :leadership
    remove_column :objective_comments, :career_aspiration
    add_column :objective_comments, :comment_type, :integer, default: 1
  end
end
