class AddStaticItemInPayItems < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_items, :is_static_item, :boolean, :default => false
  end
end
