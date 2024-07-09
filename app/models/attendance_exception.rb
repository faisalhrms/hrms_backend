class AttendanceException < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :branch_id }

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
  belongs_to  :salary_unit

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

  def salary_unit_name
    if self.salary_unit.nil?
      return "-"
    else
      return self.salary_unit.name
    end
  end

end
