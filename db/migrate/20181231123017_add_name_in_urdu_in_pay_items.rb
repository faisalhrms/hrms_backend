class AddNameInUrduInPayItems < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_items, :name_in_urdu, 	:text, :default => ""
  	add_column :pay_items, :is_urdu, 				:boolean, :default => false
  end
end
