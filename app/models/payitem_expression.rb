class PayitemExpression < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true

end
