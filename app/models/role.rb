class Role < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }

	####### Relation Ship #########
	has_many	:users, 						dependent: :restrict_with_error
	has_many	:role_permissions, 	dependent: :destroy

end
