class AddBenefitItemImpactInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :social_security_impact_allowed, 		:boolean, :default => true
		add_column :employees, :life_insurance_impact_allowed, 			:boolean, :default => true
		add_column :employees, :cell_phone_bill_impact_allowed, 		:boolean, :default => true
		add_column :employees, :fuel_impact_allowed, 								:boolean, :default => true
		add_column :employees, :cell_phone_impact_allowed, 					:boolean, :default => true
		add_column :employees, :laptop_impact_allowed, 							:boolean, :default => true
		add_column :employees, :velicle_impact_allowed, 						:boolean, :default => true
		add_column :employees, :provident_fund_impact_allowed, 			:boolean, :default => true
		add_column :employees, :eobi_impact_allowed, 								:boolean, :default => true
		add_column :employees, :incentive_impact_allowed, 					:boolean, :default => true
		add_column :employees, :vehicle_allowance_impact_allowed, 	:boolean, :default => true
		add_column :employees, :maintenance_impact_allowed, 				:boolean, :default => true
		add_column :employees, :travel_allowance_impact_allowed, 		:boolean, :default => true
		add_column :employees, :attendance_impact_allowed, 					:boolean, :default => true
  end
end
