class AddDescriptionInFixedPayItems < ActiveRecord::Migration[7.1]
  def change
  	add_column :fixed_pay_items, :description, :text
  end
end
