class AddBackDateAllowanceImpactInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :back_date_allowance_impact, :boolean, :default => false
  end
end
