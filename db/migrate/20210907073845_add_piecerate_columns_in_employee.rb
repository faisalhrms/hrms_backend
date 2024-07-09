class AddPiecerateColumnsInEmployee < ActiveRecord::Migration[7.1]
  def change
    add_column  :employees, :floor_id,  :integer
    add_column  :employees, :group_id,  :integer
    add_column  :employees, :category_id, :integer
    add_column  :employees, :incharge_id, :integer
    add_column  :employees, :line_id, :integer
  end
end
