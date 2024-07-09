class AddTaxWorkingInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :customize_tax, 	:boolean, :default => false
		add_column :employees, :tax_criteria, 	:string, 	:default => "Custom Tax Slab"
		add_column :employees, :fixed_tax_rate, :float, 	:default => 0.0
  end
end
