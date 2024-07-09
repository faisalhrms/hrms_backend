class DepartmentAllocation < ApplicationRecord

	########## Validation ############
	validates :name, 			:uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch

	has_many		:department_allocation_details, :dependent => :destroy

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

  def self.collect_department_id(department_allocations)
    department_ids = []
    department_allocations.each do |department_allocation|
      department_allocation.department_allocation_details.where(:is_selected => true).each do |detail|
        department_ids << detail.department_id
      end
    end
    return department_ids.uniq
  end

end
