class GradeAllocation < ApplicationRecord

	########## Validation ############
	validates :name, 			:uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch

	has_many		:grade_allocation_details, :dependent => :destroy

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

	def branch_name
		if self.branch.nil?
  		return "-"
  	else
  		return self.branch.name
  	end
	end

  def self.collect_grade_id(grade_allocations)
    grade_ids = []
    grade_allocations.each do |grade_allocation|
      grade_allocation.grade_allocation_details.where(:is_selected => true).each do |detail|
        grade_ids << detail.grade_id
      end
    end
    return grade_ids.uniq
  end

end
