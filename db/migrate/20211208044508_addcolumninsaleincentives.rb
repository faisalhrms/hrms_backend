class Addcolumninsaleincentives < ActiveRecord::Migration[7.1]
  def change
    add_column :sale_entries, :incentive_payable, :float, :default => 0.0
    add_column :sale_entries, :incentive_thirty, :float, :default => 0.0
    add_column :sale_entries, :incentive_ten, :float, :default => 0.0
    add_column :employee_sale_incentives, :incentive_payable, :float, :default => 0.0
    add_column :employee_sale_incentives, :incentive_thirty, :float, :default => 0.0
    add_column :employee_sale_incentives, :incentive_ten, :float, :default => 0.0
  end
end
