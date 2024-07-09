class Grade < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	validates :code, :uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to :company

	has_many		:employees, 														:dependent => :restrict_with_error
	has_many		:internees, 														:dependent => :restrict_with_error
	has_many		:temporary_staffs, 											:dependent => :restrict_with_error
	has_many    :employee_rosters,    									:dependent => :restrict_with_error
	has_many    :attendance_structures,    							:dependent => :restrict_with_error
	has_many 		:benefit_structures,   									:dependent => :restrict_with_error
	has_many 		:sms_executions,   											:dependent => :restrict_with_error
	has_many 		:email_executions,   										:dependent => :restrict_with_error
	has_many    :grade_allocation_details,    					:dependent => :restrict_with_error

end
