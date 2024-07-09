class AddTargetValueInSaleEntries < ActiveRecord::Migration[7.1]
  def change
  	add_column :sale_entries, :target_value, :float, :default => 0.0
  end
end
