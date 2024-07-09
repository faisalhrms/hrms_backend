class AddLaptopCategoryInBenefitStructures < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :laptop_category, 									:string
		add_column :employees, :actual_laptop_value, 							:float, 	:default => 0.0
		
		add_column :benefit_structures, :laptop_category, 				:string
  end
end
