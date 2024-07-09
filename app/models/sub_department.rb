class SubDepartment < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :department_id }
	validates :code, :uniqueness => { scope: :department_id }
	
	####### Relation Ship #########
	has_many		:employees, 											:dependent => :restrict_with_error
	has_many		:internees, 											:dependent => :restrict_with_error
	has_many		:temporary_staffs, 								:dependent => :restrict_with_error
	
	belongs_to 	:company
	belongs_to 	:department

end
