class AddBounsImpactInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :bonus1_impact_allowed, 	:boolean, :default => false
		add_column :employees, :bonus1_allowed, 				:boolean, :default => false
		add_column :employees, :bonus1_eligibility, 		:string
		add_column :employees, :bonus2_impact_allowed, 	:boolean, :default => false
		add_column :employees, :bonus2_allowed, 				:boolean, :default => false
		add_column :employees, :bonus2_eligibility, 		:string
		add_column :employees, :bonus3_impact_allowed, 	:boolean, :default => false
		add_column :employees, :bonus3_allowed, 				:boolean, :default => false
		add_column :employees, :bonus3_eligibility, 		:string
  end
end
