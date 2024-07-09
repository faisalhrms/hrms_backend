class AddCategoryFieldInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :category, 	:string
  end
end
