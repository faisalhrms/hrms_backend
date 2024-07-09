class CustomTaxSlab < ApplicationRecord

	########## Validation ############
	validates :name, 				:uniqueness => { scope: :company_id }
	validates :code, 				:uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company
	has_many    :custom_tax_slab_details,   :dependent => :destroy

end
