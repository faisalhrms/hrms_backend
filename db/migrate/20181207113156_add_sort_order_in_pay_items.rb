class AddSortOrderInPayItems < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_items, 	:sort_order, 						:float, 	:default => 0.0
  	add_column :pay_items, 	:part_of_gross_salary, 	:boolean, :default => false
  end
end
