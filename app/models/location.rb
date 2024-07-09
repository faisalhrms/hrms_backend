class Location < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	validates :code, :uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	has_many		:branches, 											:dependent => :restrict_with_error
	has_many		:employees, 										:dependent => :restrict_with_error
	has_many		:internees, 										:dependent => :restrict_with_error
	has_many		:temporary_staffs, 							:dependent => :restrict_with_error
	has_many		:leave_types, 									:dependent => :restrict_with_error
	has_many		:leave_allocations, 						:dependent => :restrict_with_error
	has_many		:time_slots, 										:dependent => :restrict_with_error
	has_many    :employee_rosters,    					:dependent => :restrict_with_error
	has_many    :attendance_exceptions, 				:dependent => :restrict_with_error
	has_many    :attendance_cutoffs,    				:dependent => :restrict_with_error
	has_many    :attendance_structures,    			:dependent => :restrict_with_error
	has_many    :sale_entries,    							:dependent => :restrict_with_error
	has_many    :employee_sale_incentives,  		:dependent => :restrict_with_error
	has_many 		:pay_executions,   							:dependent => :restrict_with_error
	has_many 		:benefit_structures,   					:dependent => :restrict_with_error
	has_many 		:department_allocations,   			:dependent => :restrict_with_error
	has_many 		:sms_executions,   							:dependent => :restrict_with_error
	has_many 		:email_executions,   						:dependent => :restrict_with_error
	has_many 		:grade_allocations,   					:dependent => :restrict_with_error
	has_many 		:piece_slabs,   					:dependent => :restrict_with_error

	belongs_to 	:company
	scope :mill_location, -> { where(name: ['Garment', 'Denim', 'Spinning', 'Weaving']) }
end
