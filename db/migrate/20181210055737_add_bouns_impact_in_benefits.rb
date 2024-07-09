class AddBounsImpactInBenefits < ActiveRecord::Migration[7.1]
  def change
		add_column :benefit_structures, :bonus1_allowed, 				:boolean, :default => false
		add_column :benefit_structures, :bonus1_eligibility, 		:string
		add_column :benefit_structures, :bonus2_allowed, 				:boolean, :default => false
		add_column :benefit_structures, :bonus2_eligibility, 		:string
		add_column :benefit_structures, :bonus3_allowed, 				:boolean, :default => false
		add_column :benefit_structures, :bonus3_eligibility, 		:string
  end
end
