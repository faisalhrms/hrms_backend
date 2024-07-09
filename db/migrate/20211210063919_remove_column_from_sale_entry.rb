class RemoveColumnFromSaleEntry < ActiveRecord::Migration[7.1]
  def change
    remove_column :sale_entries, :incentive_thirty, :float, :default => 0.0
    remove_column :sale_entries, :incentive_ten, :float, :default => 0.0
  end
end
