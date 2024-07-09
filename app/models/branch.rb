class Branch < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :location_id }
	validates :code, :uniqueness => { scope: :location_id }
	
	####### Relation Ship #########
	has_many		:employees, 											:dependent => :restrict_with_error
	has_many		:internees, 											:dependent => :restrict_with_error
	has_many		:temporary_staffs, 								:dependent => :restrict_with_error
	has_many		:time_slots, 											:dependent => :restrict_with_error
	has_many    :employee_rosters,    						:dependent => :restrict_with_error
	has_many    :attendance_exceptions,    				:dependent => :restrict_with_error
	has_many    :attendance_cutoffs,    					:dependent => :restrict_with_error
	has_many    :attendance_structures,    				:dependent => :restrict_with_error
	has_many    :sale_entries,    								:dependent => :restrict_with_error
	has_many    :employee_sale_incentives,    		:dependent => :restrict_with_error
	has_many 		:department_allocations,   				:dependent => :restrict_with_error
	has_many 		:sms_executions,   								:dependent => :restrict_with_error
	has_many 		:email_executions,   							:dependent => :restrict_with_error
	has_many 		:grade_allocations,   						:dependent => :restrict_with_error
	has_many    :request_flow_details,  					:dependent => :restrict_with_error

	belongs_to 	:company
	belongs_to 	:location

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def location_name
  	if self.location.nil?
  		return "-"
  	else
  		return self.location.name
  	end
  end
  
end
