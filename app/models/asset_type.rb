class AssetType < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => true
	
end
