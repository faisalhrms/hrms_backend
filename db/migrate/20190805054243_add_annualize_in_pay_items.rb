class AddAnnualizeInPayItems < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_items, 								:annualize, 													:boolean, :default => false
  	add_column :employee_taxable_incomes, :annualize_predicated_taxable_amount, :float, :default => 0.0
  end
end
