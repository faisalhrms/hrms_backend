class Department < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	validates :code, :uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	has_many		:sub_departments, 									:dependent => :restrict_with_error
	has_many		:employees, 												:dependent => :restrict_with_error
	has_many		:internees, 												:dependent => :restrict_with_error
	has_many		:temporary_staffs, 									:dependent => :restrict_with_error
	has_many    :employee_rosters,    							:dependent => :restrict_with_error
	has_many    :attendance_structures,    					:dependent => :restrict_with_error
	has_many    :department_allocation_details,    	:dependent => :restrict_with_error
	has_many    :request_flow_details,  						:dependent => :restrict_with_error	
	
	belongs_to 	:company
	
end
