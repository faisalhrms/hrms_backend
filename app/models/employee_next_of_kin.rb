class EmployeeNextOfKin < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:employee
	belongs_to 	:employee_relative
	belongs_to 	:guardian, 						foreign_key: :guardian_id, 	:class_name => "EmployeeRelative"
	belongs_to 	:relationship

	def employee_relative_name
		if self.employee_relative.nil?
  		return "-"
  	else
  		return self.employee_relative.relative_name
  	end
	end

	def guardian_name
		if self.guardian.nil?
  		return "-"
  	else
  		return self.guardian.relative_name
  	end
	end

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
