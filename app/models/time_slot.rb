class TimeSlot < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :branch_id }
	validates :code, :uniqueness => { scope: :branch_id }
	
	####### Relation Ship #########
  has_many    :employee_rosters,    :dependent => :restrict_with_error
  has_many    :sub_time_slots,      :dependent => :restrict_with_error
	has_many		:break_times, 	      :dependent => :destroy

	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch

  ####### Callback #########
  after_save  :update_employee_roster

  def update_employee_roster
    self.employee_rosters.where(:is_transfer => false).update_all(
      is_flexi: self.is_flexi,
      start_time:  self.start_time,
      end_time:  self.end_time,
      formated_start_time: self.actual_start_time,
      formated_end_time:   self.actual_end_time,
      start_buffer: self.start_buffer,
      end_buffer: self.end_buffer)
  end

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

end
