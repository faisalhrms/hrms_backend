class AddItemsInBenefitStructures < ActiveRecord::Migration[7.1]
  def change
  	add_column :benefit_structures, :social_security_allowed, 							:boolean, :default => false
		add_column :benefit_structures, :social_security_eligibility, 					:string
		add_column :benefit_structures, :social_security_joining_salary, 				:float, 	:default => 0.0
		add_column :benefit_structures, :life_insurance_allowed, 								:boolean, :default => false
		add_column :benefit_structures, :life_insurance_eligibility, 						:string
		add_column :benefit_structures, :life_insurance_value, 									:float, 	:default => 0.0
		add_column :benefit_structures, :cell_phone_bill_allowed, 							:boolean, :default => false
		add_column :benefit_structures, :cell_phone_bill_eligibility, 					:string
		add_column :benefit_structures, :cell_phone_bill_limit, 								:string
		add_column :benefit_structures, :cell_phone_bill_amount, 								:float, 	:default => 0.0
		add_column :benefit_structures, :fuel_allowed, 													:boolean, :default => false
		add_column :benefit_structures, :fuel_eligibility, 											:string
		add_column :benefit_structures, :fuel_limit, 														:string
		add_column :benefit_structures, :fuel_value, 														:float, 	:default => 0.0
		add_column :benefit_structures, :cell_phone_allowed, 										:boolean, :default => false
		add_column :benefit_structures, :cell_phone_eligibility, 								:string
		add_column :benefit_structures, :cell_phone_entitlement_upto, 					:float, 	:default => 0.0
		add_column :benefit_structures, :laptop_allowed, 												:boolean, :default => false
		add_column :benefit_structures, :laptop_eligibility, 										:string
		add_column :benefit_structures, :laptop_entitlement_upto, 							:float, 	:default => 0.0
		add_column :benefit_structures, :velicle_allowed, 											:boolean, :default => false
		add_column :benefit_structures, :velicle_eligibility, 									:string
		add_column :benefit_structures, :provident_fund_allowed, 								:boolean, :default => false
		add_column :benefit_structures, :provident_fund_eligibility, 						:string
		add_column :benefit_structures, :eobi_allowed, 													:boolean, :default => false
		add_column :benefit_structures, :eobi_eligibility, 											:string
		add_column :benefit_structures, :incentive_allowed, 										:boolean, :default => false
		add_column :benefit_structures, :incentive_eligibility, 								:string
		add_column :benefit_structures, :vehicle_allowance_allowed, 						:boolean, :default => false
		add_column :benefit_structures, :vehicle_allowance_eligibility, 				:string
		add_column :benefit_structures, :vehicle_allowance_entitlement_upto, 		:float, 	:default => 0.0
		add_column :benefit_structures, :maintenance_allowed, 									:boolean, :default => false
		add_column :benefit_structures, :maintenance_eligibility, 							:string
		add_column :benefit_structures, :maintenance_entitlement_upto, 					:float, 	:default => 0.0
		add_column :benefit_structures, :travel_allowance_allowed, 							:boolean, :default => false
		add_column :benefit_structures, :travel_allowance_eligibility, 					:string
		add_column :benefit_structures, :travel_allowance_entitlement_upto, 		:float, 	:default => 0.0
		add_column :benefit_structures, :attendance_allowed, 										:boolean, :default => false
		add_column :benefit_structures, :overtime_allowed, 											:boolean, :default => false
		add_column :benefit_structures, :cpl_allowed, 													:boolean, :default => false
		add_column :benefit_structures, :off_day_allowed, 											:boolean, :default => false
  end
end