class EmployeeReference < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:employee

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
