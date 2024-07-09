class DepartmentAllocationDetail < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:department
	belongs_to 	:department_allocation


	def department_name
  	if self.department.nil?
  		return "-"
  	else
  		return self.department.name
  	end
  end

  def department_allocation_name
  	if self.department_allocation.nil?
  		return "-"
  	else
  		return self.department_allocation.name
  	end
  end

end
