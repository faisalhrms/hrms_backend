class AttendanceExecutionTransaction < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:department

	def actual_company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def actual_location_name
  	if self.location.nil?
  		return "-"
  	else
  		return self.location.name
  	end
  end

  	def actual_branch_name
  	if self.branch.nil?
  		return "-"
  	else
  		return self.branch.name
  	end
  end

  def actual_department_name
  	if self.department.nil?
  		return "-"
  	else
  		return self.department.name
  	end
  end

end
