class AddBackDateEobiImpactInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :back_date_eobi_impact, 	:boolean, :default => false
  	add_column :employees, :back_date_pf_impact, 		:boolean, :default => false
  end
end
