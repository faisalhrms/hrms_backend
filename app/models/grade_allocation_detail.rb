class GradeAllocationDetail < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:grade
	belongs_to 	:grade_allocation


	def grade_name
  	if self.grade.nil?
  		return "-"
  	else
  		return self.grade.name
  	end
  end

  def grade_allocation_name
  	if self.grade_allocation.nil?
  		return "-"
  	else
  		return self.grade_allocation.name
  	end
  end
  
end
