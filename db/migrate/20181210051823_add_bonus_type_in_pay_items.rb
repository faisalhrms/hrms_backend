class AddBonusTypeInPayItems < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_items, :bonus_type, :string
  end
end
