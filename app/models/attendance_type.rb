class AttendanceType < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	validates :code, :uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to 	:company

	has_many    :attendance_deductions,    				:dependent => :restrict_with_error
	has_many		:relaxation_requests, 						:dependent => :restrict_with_error

end
