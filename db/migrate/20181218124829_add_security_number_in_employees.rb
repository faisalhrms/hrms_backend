class AddSecurityNumberInEmployees < ActiveRecord::Migration[7.1]
  def change
		add_column :employees, :security_number, 									:string
		add_column :employees, :health_insurance_impact_allowed, 	:boolean, :default => true
		add_column :employees, :health_insurance_allowed, 				:boolean, :default => false
		add_column :employees, :health_insurance_plan, 						:string
		add_column :employees, :health_insurance_eligibility, 		:string

		add_column :benefit_structures, :health_insurance_allowed, 				:boolean, :default => false
		add_column :benefit_structures, :health_insurance_plan, 					:string
		add_column :benefit_structures, :health_insurance_eligibility, 		:string
  end
end
