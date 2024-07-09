class AddColumnsToObjectiveComments < ActiveRecord::Migration[7.1]
  def change
    add_column  :objective_comments,  :type,  :integer, :default => 0
    add_column  :objective_comments,  :employee_comments, :string
    add_column  :objective_comments,  :functional,  :string
    add_column  :objective_comments,  :leadership,  :string
    add_column  :objective_comments,  :career_aspiration, :string
    add_column  :objective_comments,  :line_manager_approval, :string,  :default => "Pending"
    add_column  :objective_comments,  :status,  :string,  :default => "Pending"
  end
end
