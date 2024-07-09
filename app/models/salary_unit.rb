class SalaryUnit < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	has_many		:employees, 						:dependent => :restrict_with_error
	has_many		:internees, 						:dependent => :restrict_with_error
	has_many		:temporary_staffs, 			:dependent => :restrict_with_error
	has_many		:cost_centers, 					:dependent => :restrict_with_error

end
