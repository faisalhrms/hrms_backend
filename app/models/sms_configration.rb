class SmsConfigration < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company
	has_many		:sms_templates, 	:dependent => :restrict_with_error
	
end
