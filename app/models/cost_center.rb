class CostCenter < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :salary_unit_id }
	
	####### Relation Ship #########
	has_many		:employees, 					:dependent => :restrict_with_error
	has_many		:internees, 					:dependent => :restrict_with_error
	has_many		:temporary_staffs, 		:dependent => :restrict_with_error

	belongs_to :company
	belongs_to :salary_unit

end
