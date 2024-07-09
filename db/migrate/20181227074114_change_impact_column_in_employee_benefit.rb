class ChangeImpactColumnInEmployeeBenefit < ActiveRecord::Migration[7.1]
  def change
  	change_column :employees, :social_security_impact_allowed, 		:boolean, :default => false
		change_column :employees, :life_insurance_impact_allowed, 		:boolean, :default => false
		change_column :employees, :health_insurance_impact_allowed, 	:boolean, :default => false
		change_column :employees, :cell_phone_bill_impact_allowed, 		:boolean, :default => false
		change_column :employees, :fuel_impact_allowed, 							:boolean, :default => false
		change_column :employees, :cell_phone_impact_allowed, 				:boolean, :default => false
		change_column :employees, :laptop_impact_allowed, 						:boolean, :default => false
		change_column :employees, :velicle_impact_allowed, 						:boolean, :default => false
		change_column :employees, :provident_fund_impact_allowed, 		:boolean, :default => false
		change_column :employees, :eobi_impact_allowed, 							:boolean, :default => false
		change_column :employees, :incentive_impact_allowed, 					:boolean, :default => false
		change_column :employees, :vehicle_allowance_impact_allowed, 	:boolean, :default => false
		change_column :employees, :maintenance_impact_allowed, 				:boolean, :default => false
		change_column :employees, :travel_allowance_impact_allowed, 	:boolean, :default => false
		change_column :employees, :attendance_impact_allowed, 				:boolean, :default => false
		change_column :employees, :gratuity_impact_allowed, 					:boolean, :default => false
		change_column :employees, :lfa_impact_allowed, 								:boolean, :default => false
		change_column :employees, :house_allowance_impact_allowed, 		:boolean, :default => false
		change_column :employees, :bonus1_impact_allowed, 						:boolean, :default => false
		change_column :employees, :bonus2_impact_allowed, 						:boolean, :default => false
		change_column :employees, :bonus3_impact_allowed, 						:boolean, :default => false
  end
end
