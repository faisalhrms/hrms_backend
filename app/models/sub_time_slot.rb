class SubTimeSlot < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :time_slot_id }
	validates :code, :uniqueness => { scope: :time_slot_id }
	
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:time_slot

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

  def time_slot_name
    if self.time_slot.nil?
      return "-"
    else
      return self.time_slot.name
    end
  end

end
