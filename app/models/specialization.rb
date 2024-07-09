class Specialization < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true

	has_many 	:employee_qualifications, 		:dependent => :restrict_with_error
	
end
