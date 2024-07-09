class SmsTemplate < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:sms_configration

	has_many 		:sms_executions,   								:dependent => :restrict_with_error
	
end
