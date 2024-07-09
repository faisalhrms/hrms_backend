class TaxSlab < ApplicationRecord

	########## Validation ############
	validates :name, 				:uniqueness => { scope: :company_id }
	validates :code, 				:uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company
	has_many    :tax_slab_details,   :dependent => :destroy

	has_many 		:pay_executions,   	:dependent => :restrict_with_error

end
