class AddShopIdInBranches < ActiveRecord::Migration[7.1]
  def change
  	add_column :branches, :shop_id, :integer
  end
end
