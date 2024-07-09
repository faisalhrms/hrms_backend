class AddSortOrderInGrades < ActiveRecord::Migration[7.1]
  def change
  	add_column :grades, :sort_order, :integer, :default => 0
  end
end
