class AddLfaInBenefitStructures < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :gratuity_impact_allowed, 					:boolean, :default => true
		add_column :employees, :gratuity_allowed, 								:boolean, :default => false
		add_column :employees, :gratuity_eligibility, 						:string
		add_column :employees, :gratuity_other_date, 							:datetime
  	add_column :employees, :lfa_impact_allowed, 							:boolean, :default => true
		add_column :employees, :lfa_allowed, 											:boolean, :default => false
		add_column :employees, :lfa_eligibility, 									:string
		add_column :employees, :lfa_other_date, 									:datetime
		add_column :employees, :house_allowance_impact_allowed, 	:boolean, :default => true
		add_column :employees, :house_allowance_allowed, 					:boolean, :default => false
		add_column :employees, :house_allowance_eligibility, 			:string
		add_column :employees, :house_allowance_other_date, 			:datetime
  	
		add_column :benefit_structures, :gratuity_allowed, 									:boolean, :default => false
		add_column :benefit_structures, :gratuity_eligibility, 							:string
		add_column :benefit_structures, :lfa_allowed, 											:boolean, :default => false
		add_column :benefit_structures, :lfa_eligibility, 									:string
		add_column :benefit_structures, :house_allowance_allowed, 					:boolean, :default => false
		add_column :benefit_structures, :house_allowance_eligibility, 			:string
  end
end
