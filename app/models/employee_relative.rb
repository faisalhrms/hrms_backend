class EmployeeRelative < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:employee
	belongs_to 	:relationship

	has_many :employee_next_of_kins, 	:dependent => :restrict_with_error

	def relationship_name
		if self.relationship.nil?
  		return "-"
  	else
  		return self.relationship.name
  	end
	end

	def employee_name
		if self.employee.nil?
			return "-"
		else
			self.employee.full_name
		end
	end

	def employee_code
		if self.employee.nil?
			return "-"
		else
			self.employee.employee_code
		end
	end

end
