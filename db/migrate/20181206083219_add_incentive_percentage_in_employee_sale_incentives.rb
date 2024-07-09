class AddIncentivePercentageInEmployeeSaleIncentives < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_sale_incentives, :incentive_percentage, :float, :default => 0.0
  end
end
