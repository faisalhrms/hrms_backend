class Country < ApplicationRecord

	####### Relation Ship #########
	has_many		:states
	has_many		:divisions
	has_many		:districts
	has_many		:tehsils

end
