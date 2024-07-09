class AssetDetail < ApplicationRecord

	########## Validation ############
	validates :item_name, 				:uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company

end
