class AddLineManagerIdInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :line_manager_id, :integer
  end
end
