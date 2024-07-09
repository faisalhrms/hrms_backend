class AddBenefitItemsInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :social_security_allowed, 							:boolean, :default => false
		add_column :employees, :social_security_eligibility, 					:string
		add_column :employees, :social_security_joining_salary, 			:float, 	:default => 0.0
		add_column :employees, :life_insurance_allowed, 							:boolean, :default => false
		add_column :employees, :life_insurance_eligibility, 					:string
		add_column :employees, :life_insurance_value, 								:float, 	:default => 0.0
		add_column :employees, :cell_phone_bill_allowed, 							:boolean, :default => false
		add_column :employees, :cell_phone_bill_eligibility, 					:string
		add_column :employees, :cell_phone_bill_limit, 								:string
		add_column :employees, :cell_phone_bill_amount, 							:float, 	:default => 0.0
		add_column :employees, :fuel_allowed, 												:boolean, :default => false
		add_column :employees, :fuel_eligibility, 										:string
		add_column :employees, :fuel_limit, 													:string
		add_column :employees, :fuel_value, 													:float, 	:default => 0.0
		add_column :employees, :cell_phone_allowed, 									:boolean, :default => false
		add_column :employees, :cell_phone_eligibility, 							:string
		add_column :employees, :cell_phone_entitlement_upto, 					:float, 	:default => 0.0
		add_column :employees, :laptop_allowed, 											:boolean, :default => false
		add_column :employees, :laptop_eligibility, 									:string
		add_column :employees, :laptop_entitlement_upto, 							:float, 	:default => 0.0
		add_column :employees, :velicle_allowed, 											:boolean, :default => false
		add_column :employees, :velicle_eligibility, 									:string
		add_column :employees, :provident_fund_allowed, 							:boolean, :default => false
		add_column :employees, :provident_fund_eligibility, 					:string
		add_column :employees, :eobi_allowed, 												:boolean, :default => false
		add_column :employees, :eobi_eligibility, 										:string
		add_column :employees, :incentive_allowed, 										:boolean, :default => false
		add_column :employees, :incentive_eligibility, 								:string
		add_column :employees, :vehicle_allowance_allowed, 						:boolean, :default => false
		add_column :employees, :vehicle_allowance_eligibility, 				:string
		add_column :employees, :vehicle_allowance_entitlement_upto, 	:float, 	:default => 0.0
		add_column :employees, :maintenance_allowed, 									:boolean, :default => false
		add_column :employees, :maintenance_eligibility, 							:string
		add_column :employees, :maintenance_entitlement_upto, 				:float, 	:default => 0.0
		add_column :employees, :travel_allowance_allowed, 						:boolean, :default => false
		add_column :employees, :travel_allowance_eligibility, 				:string
		add_column :employees, :travel_allowance_entitlement_upto, 		:float, 	:default => 0.0
  end
end
