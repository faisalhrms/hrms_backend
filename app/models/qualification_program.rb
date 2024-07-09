class QualificationProgram < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true

	####### Relation Ship #########
	has_many 	:employee_qualifications, 		:dependent => :restrict_with_error
	
end
