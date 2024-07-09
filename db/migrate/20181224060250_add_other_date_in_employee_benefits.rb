class AddOtherDateInEmployeeBenefits < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :social_security_other_date, 		:datetime
		add_column :employees, :life_insurance_other_date, 			:datetime
		add_column :employees, :cell_phone_bill_other_date, 		:datetime
		add_column :employees, :fuel_other_date, 								:datetime
		add_column :employees, :cell_phone_other_date, 					:datetime
		add_column :employees, :laptop_other_date, 							:datetime
		add_column :employees, :velicle_other_date, 						:datetime
		add_column :employees, :provident_fund_other_date, 			:datetime
		add_column :employees, :eobi_other_date, 								:datetime
		add_column :employees, :incentive_other_date, 					:datetime
		add_column :employees, :vehicle_allowance_other_date, 	:datetime
		add_column :employees, :maintenance_other_date, 				:datetime
		add_column :employees, :travel_allowance_other_date, 		:datetime
		add_column :employees, :bonus1_other_date, 							:datetime
		add_column :employees, :bonus2_other_date, 							:datetime
		add_column :employees, :bonus3_other_date, 							:datetime
		add_column :employees, :health_insurance_other_date, 		:datetime
  end
end
