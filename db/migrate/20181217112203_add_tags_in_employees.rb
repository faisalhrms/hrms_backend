class AddTagsInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :tags, :string
  end
end
