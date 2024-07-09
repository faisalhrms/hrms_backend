class LeftReason < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true

end
