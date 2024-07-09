class AddTargetValueInEmployeeSaleIncentives < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_sale_incentives, :target_value, :float, :default => 0.0
  end
end
