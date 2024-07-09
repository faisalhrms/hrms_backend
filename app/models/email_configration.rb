class EmailConfigration < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company
	has_many		:email_templates, 			:dependent => :restrict_with_error
	has_many		:email_outbounds, 			:dependent => :restrict_with_error

end
