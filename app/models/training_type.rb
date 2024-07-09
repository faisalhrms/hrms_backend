class TrainingType < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true

end
