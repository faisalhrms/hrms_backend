class CertificationType < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true
	
end
