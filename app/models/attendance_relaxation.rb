class AttendanceRelaxation < ApplicationRecord

	########## Validation ############
	validates :name, 		:uniqueness => { scope: :company_id }
	validates :code, 		:uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to 	:company
	has_many    :attendance_relaxation_slabs,    	:dependent => :restrict_with_error
	has_many    :attendance_structures,    				:dependent => :restrict_with_error

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

end
