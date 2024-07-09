class AddColumnsInObjectiveSettings < ActiveRecord::Migration[7.1]
  def change
    add_column  :objective_settings,  :status, :string
    add_column  :objective_settings,  :comments,  :string
  end
end
