class EmailTemplate < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to :company
	belongs_to :email_configration

	has_many	 :email_outbounds, 			:dependent => :restrict_with_error

end
