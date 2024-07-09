class Eobi < ApplicationRecord

	########## Validation ############
	validates :name, 				:uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company

	has_many 		:pay_executions,   	:dependent => :restrict_with_error
	
end
