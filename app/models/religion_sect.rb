class ReligionSect < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true

	####### Relation Ship #########
	has_many	:employees, 					:dependent => :restrict_with_error
	
end
