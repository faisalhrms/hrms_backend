class EmployeeType < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true

	####### Relation Ship #########
	has_many		:employees, 									:dependent => :restrict_with_error
	has_many 		:benefit_structures,   				:dependent => :restrict_with_error
	
end
