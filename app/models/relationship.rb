class Relationship < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true

	####### Relation Ship #########
	has_many		:employees, 									:dependent => :restrict_with_error
	has_many		:employee_relatives, 					:dependent => :restrict_with_error
	has_many		:employee_next_of_kins, 			:dependent => :restrict_with_error
	
end
